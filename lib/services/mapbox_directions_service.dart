import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mapbox_config.dart';

/// Service providing real street-by-street road network routing
/// and day-by-day theme color coding.
class MapboxDirectionsService {
  /// In-memory cache for dynamically fetched or decoded routes
  static final Map<int, List<({double lat, double lng})>> _dayRouteCache = {};
  static final Map<String, List<({double lat, double lng})>> _signatureRouteCache = {};

  /// Distinct signature color code for each day of the journey
  static Color getDayColor(int dayNumber) {
    switch (dayNumber) {
      case 1:
        return const Color(0xFFFF5B22); // Vibrant Coral Orange
      case 2:
        return const Color(0xFF00B894); // Emerald Mint Green
      case 3:
        return const Color(0xFF2563EB); // Royal Sapphire Blue
      case 4:
        return const Color(0xFF8B5CF6); // Amethyst Purple
      case 5:
        return const Color(0xFFF43F5E); // Vivid Rose Pink
      default:
        return const Color(0xFFFF7A00);
    }
  }

  /// Subtle tint of the day's color for badges and background accents
  static Color getDayLightColor(int dayNumber) {
    return getDayColor(dayNumber).withValues(alpha: 0.12);
  }

  /// Synchronously returns the real street route for a given day.
  /// Decodes and caches the road network points turn-by-turn.
  static List<({double lat, double lng})> getRealRouteForDay(int dayNumber) {
    if (_dayRouteCache.containsKey(dayNumber)) {
      return _dayRouteCache[dayNumber]!;
    }

    final encoded = _precomputedPolylines[dayNumber];
    if (encoded != null) {
      final decoded = decodePolyline(encoded);
      _dayRouteCache[dayNumber] = decoded;
      return decoded;
    }

    return const [];
  }

  /// Synchronous fallback / cached route for any sequence of waypoints
  static List<({double lat, double lng})> getSyncRouteForCoordinates({
    required List<({double lat, double lng})> waypoints,
    int? dayNumber,
  }) {
    if (waypoints.length < 2) return waypoints;
    final sig = _getSignature(waypoints);
    if (_signatureRouteCache.containsKey(sig)) {
      return _signatureRouteCache[sig]!;
    }
    if (dayNumber != null && _precomputedPolylines.containsKey(dayNumber)) {
      return getRealRouteForDay(dayNumber);
    }
    return waypoints;
  }

  /// Asynchronously fetches real turn-by-turn road network routes along actual streets.
  /// Uses Mapbox Directions API and OpenStreetMap OSRM with instant memory caching.
  /// Cross-platform: works on Web, Mobile, and Desktop via package:http.
  static Future<List<({double lat, double lng})>> fetchRealRouteForCoordinates({
    required List<({double lat, double lng})> waypoints,
    String? token,
    int? dayNumber,
  }) async {
    if (waypoints.length < 2) return waypoints;
    final sig = _getSignature(waypoints);
    if (_signatureRouteCache.containsKey(sig)) {
      return _signatureRouteCache[sig]!;
    }

    final coordsParam = waypoints
        .map((w) => '${w.lng.toStringAsFixed(6)},${w.lat.toStringAsFixed(6)}')
        .join(';');

    // 1. Try Mapbox Directions API if access token is available
    final activeToken = (token != null && token.trim().isNotEmpty)
        ? token.trim()
        : MapboxConfig.defaultAccessToken.trim();

    if (activeToken.isNotEmpty) {
      try {
        final uri = Uri.parse(
          'https://api.mapbox.com/directions/v5/mapbox/driving/$coordsParam'
          '?geometries=polyline&overview=full&access_token=$activeToken',
        );
        final response = await http.get(uri).timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final routes = json['routes'] as List<dynamic>?;
          if (routes != null && routes.isNotEmpty) {
            final polyline = routes[0]['geometry'] as String;
            final decoded = decodePolyline(polyline);
            if (decoded.isNotEmpty) {
              _signatureRouteCache[sig] = decoded;
              return decoded;
            }
          }
        }
      } catch (_) {}
    }

    // 2. Try OpenStreetMap OSRM public driving directions (Free fallback)
    try {
      final osrmUri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coordsParam'
        '?overview=full&geometries=polyline',
      );
      final response = await http.get(osrmUri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final routes = json['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final polyline = routes[0]['geometry'] as String;
          final decoded = decodePolyline(polyline);
          if (decoded.isNotEmpty) {
            _signatureRouteCache[sig] = decoded;
            return decoded;
          }
        }
      }
    } catch (_) {}

    // 3. Fallback to precomputed day road route
    if (dayNumber != null && _precomputedPolylines.containsKey(dayNumber)) {
      return getRealRouteForDay(dayNumber);
    }

    return waypoints;
  }

  static String _getSignature(List<({double lat, double lng})> waypoints) {
    return waypoints
        .map((w) => '${w.lat.toStringAsFixed(4)},${w.lng.toStringAsFixed(4)}')
        .join('|');
  }

  /// Standard Google / Mapbox Polyline algorithm decoder.
  /// Uses arithmetic negation -((result >> 1) + 1) instead of bitwise NOT ~(result >> 1)
  /// so it works correctly across both 64-bit Dart VM and Dart Web / dart2js runtimes.
  static List<({double lat, double lng})> decodePolyline(String encoded) {
    final List<({double lat, double lng})> points = [];
    int index = 0;
    final len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0 ? -((result >> 1) + 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0 ? -((result >> 1) + 1) : (result >> 1));
      lng += dlng;

      points.add((lat: lat / 1E5, lng: lng / 1E5));
    }
    return points;
  }

  /// Precomputed real road network polylines from Mapbox Directions API for Days 1 through 5.
  /// Raw string literals (r'...') preserve all escape characters precisely.
  static final Map<int, String> _precomputedPolylines = {
    1: r'oguxE_~usY[f@cB}AdAgCXq@r@aBQMgB}A{AwAqAiAmAgAKImAeA_@Wg@_@gA]OGa@UOI??A?g@`@sBfB_@VYNUL[H[H]DS@WBE`@OnAYrCAL?LAR?J@VBXFVR|@Nl@DPJb@\zAH\DLFXBN@F@F?PEd@Ef@ANCRCPOAMAWAU@QBG@SFa@L}An@c@PqBt@mAp@UPUNYPgAVWDk@LMDoBZu@NSBa@FcBZ]FODSFSH]PoAx@KHMFsAbAaAp@y@p@e@N]Ji@HU@_@?I?W?BVFh@PpB@LH`ABVDRPb@?Jb@j@b@Zr@\v@L?`@G~AERx@nAlAjAjAt@dAQz@UVItAe@~A_A`@WXQVOb@WN`@J`@B`@O`@AR?Z@d@ORAJO@kBLG@GY]k@c@]EQAGuAd@WH{@TeAPkAu@mAkAy@oADSF_B?a@w@Ms@]c@[c@k@?KQc@ESCWIaAAMQqBGi@CWAQX@H?T?ZCRATERGPGLGnA_Af@[`Aq@`@[LIJId@]^U\Ud@Qh@MPEDAh@ILCf@I^GTEt@O??v@Mx@OJCl@KBA|@OXKXSTMDPFVt@bC|@|ALRNRFJxBfDN`@d@lBJd@BPBLBFBFDBDBr@Rh@Td@RRFPFb@HNBPBdAP^FTBT?X?j@CN?L?N@B?p@Bb@DF?d@DR@Vt@Vr@BHHTWEGQ[_AGQMa@e@EG?c@Eu@COAM?O?k@BY?U?UC_@G]Gg@IQCOCc@IQGSGe@Si@Us@SECECI@MAQEyBg@GKQa@|@y@l@a@BAJId@lBJd@BPBLBFBFDBDBr@Rh@Td@RRFPFb@HNBPBdAP^FTBT?X?j@CN?L?N@t@Bb@DF?d@DR@Vt@Vr@BHHTZDl@HVBd@D`@D\BvGVb@@b@BrAJh@F|B`@ZD~@FPBzAJnBJH@\@NTHJHJJHLHDBDBF@FBD@F?L@rA?T?X@|CAR?L?H?P?jA?^@DUDg@nCFV?P?A\?X??AFAf@ALEv@AFABAL?LAL?J?PN?F@B@^FJ@LC`@a@RtARt@?@Xr@d@bA@Ah@WNg@@Il@iAVk@^y@JEl@UHERICOe@iBAIGSs@_D]}Ao@oCEe@CWO_CBa@Es@Ee@EWIm@Gw@?OGgFCkC?gAG{DAk@C_@[aHUuFEw@IgCAQEoAAOIaBCk@GwAIsBEcAEy@AOA[GoAQgDUoFKuBEgBKkBIaCMiFEqCAwBEk@I_AE_@Ea@MeAKu@Mq@Mq@_DoM{@eDQm@O_@GQaAaCiAsCqAqDgDmJaBeEkCkGkBwEoBqE[y@[aAGSEUCQAU?Y?W@QBQDOBMFKFKHKHIHEHEHCJCHAJALAH?fAFh@Fd@HdBX|B^|Dp@nDh@b@Fb@JZLd@Rf@XlBxAl@`@XLXLXJVFZFxARnAPTBR@N?LARCJCNCLEPEXK^OlDiBXOl@_@HIJINQJOJOBIDKDKDQBQD]De@b@_IBg@Dc@Fc@Hg@d@mCF_@F_@B]De@l@yOBe@Dc@DWDUFQFQJSHMJOJMLQNOt@k@TSPQPSPYNWHSFSFUF[F_@Di@VmE@c@@a@A_@CWCSEWGWGSIWa@iAIWIUEWEWAWAY?Y@YB[BYl@iG^yDF{@FiAFqAViGPyEDaAFkBBc@D_@D_@FYDSDOFOHOFMHKHKFGFEHEFEJELEJCLCNANAP?N@P@NBVFFBTFZLxElB`NtFhC`ALDNBLBN@L@P?TAVCRETGpAg@TIVIVGTCPEZCVCd@Ch@AhBAhC?pGAxEAbD?n@?\?ZANCNARERGPGRIPINKNKPONQNQNUP[N]L_@L[Jc@No@~Mmn@t@sDF]F]D[B[DY@[B]@]?_@?_@?]A]C]E]Ec@Ge@Ki@Ke@Ia@K_@Ka@qByHI]Sw@Mo@Os@Ko@Kq@Kw@K{@Is@Em@Eq@Cq@Ai@?i@?g@@c@@e@Bc@Di@Dg@Hk@Hg@He@Jc@Ng@Ng@Pg@Re@Te@Ve@Va@V_@Za@b@e@b@c@~BoBjCuBz@_Al@w@jAuA~@gAZ[TYPYNUHUJWFYDYB[@]?]A]C[EYI[K[KYK[eGiN_@eA]uAgByDuG}NoAsBo@sAs@yAsDyHYi@Wa@S[OUOQQQOMOGQIQGSCUCS?U@SBSBQFQHOHeFdDyG~EsGpEgDnCwHzFeFzDa@X]JyApAkA~@QNUP]i@MSsBmDiAkBOUTULP`E|GJP\n@UPSRsDhDwBxBg@h@gAbByApBkCpCeEdEkArAi@h@kBtAiAx@uAbAWTeAfAgAfAQRPRHLdClENTpCxEPVLTvBnDVb@PQ`@c@`CuBrBgBnYkV~EeE',
    2: r'}y}xEavbtYB?j@DD?d@Bb@A`@A_@jBERFBETEf@CJANCHEFIBg@Hi@H]F_ANo@LKB_@J[La@ROHQHWNWLQJEGIEUAm@DE?c@YKOGIMKA?CACCUBIDQF[RC@IDGDG@G@]FK@QD[BE@K?Q?EDAL@JHHFHDJ`AlBFFHAt@]HCDDDFzBwApAs@HGNIPKVMVOPINI`@SZM^KJCn@M~@O\Gh@If@IHCDGBI@OBKDg@DUVH~@^PFRD\FXD~@PtARTBn@HnAPZDXFZFrATLB@@NDLF^Px@`@TLXJvB~@NDdBHP@N?hAFZ@P@xBN\BlBLT@N@T@bBJtAFhAHP?L@jAFtDPf@BF@^@VBt@BtBLH?F@L?N@n@D`ADB?f@DDa@@iA@}@?y@@K?OK?C?_BAGN?x@?J?P?j@A~@?L?R`ADB?f@DPDIXOCg@E{@Ec@AOAOAI?C?QCyAIiAGI?WCA\?JCl@Cp@?JCh@IfCCz@AJ?TZB`@DjBRL@b@BL?L?HBNFj@V@BV\VLFFf@ZZPp@b@^TpA~@HFx@PVFd@L\DJ?V?XAN?T?HAN?Nh@tAxE`@rAFTDLJl@TCL?n@HN@h@F\FTBRBb@Ft@HvAPXD\DbC^H@vBVN@TBxBTVB\Dp@J`@F`AP\Fn@JnARLBTDLBrBZ~AVF@PBJBPDpAVVFpCl@F@\HTDVDxGnAFBXFZFxCp@J@`@JlAXZH`E|@tEdAxEjAHBTFVDZHvD|@jEhA~Ct@TFTJVJBBPJXX\c@`@o@j@_A\i@JO?AXc@HMb@w@JSh@aAFKLUXi@hAuBx@uAFKNWJOPYVc@^m@JQFKt@kA^g@@K?GCGc@c@aBeBGGh@y@FIFMDIJJpBtBFHVVNNGJQVo@~@_@j@w@hAIJKPYd@Yb@EFOXKNQVYl@[VoA~BILSp@MTm@hAMR]l@',
    3: r'mcsxE}u}sYABI\_@pGG`AEt@KjBAH?RNF\Hl@JL@V?n@?PBVFTJTLIPOISGMCQEQ?UA_@?SCSA_@IUGICQGe@Ug@YqAw@{A{@UMWGKCWECTW~@Of@JHZZTRTR~@v@Wj@a@j@CDCDILEHQN[TGDWXE@UKs@[GACAUGICy@~BIPMr@G`@CR?X@b@BNBLDRL^N\JXDNBRBp@?RCPM`@aA~C_@pAIXCHsAlECLCDw@nCg@jBMf@GTERMd@c@pBa@lBKj@CJCRu@jDAJGVIb@[hBENY~@o@|AFDr@v@HH@JFJBBHHPF~AGv@CxCh@dCb@bAPTRNX[JC@EHoA^[Pa@^SXQVKVGR[lAm@`CERFNDL@DRd@HCPGVIFAD?B?BB@B@F?DADC@KDa@JKBQTCDAD@BNr@F^JJ@FADCJKEOUEOMo@EYCSJ[BGBEDAFEHCPGVIFAD?B?F@XNB@JLVXFPF^BP?PAVEJIHOJg@R[BOCUKKEOUEOMo@EYCSJ[BGBEDAFESe@AEEMGOkA~Ek@jAi@nAq@nAQZU\WZUREDyBtByCvCgEjDGFKJYRq@NwBXe@H_ANqATg@HMB_Dh@eJpAE@G@UBm@@YESGe@UWUMMSUQWQQKIMGWMICICQAS@QDQHc@L]JcBf@]JWJe@LIDmAd@wClAKFKJIJIRGVM^KXOZMTKNCDKJKHUNSLmCjAgFtBYNYNaHzCc@PaE`Bg@R]N]NIB@VC^u@pKe@`HAXAJCJGHILEBGDEBKBM?I?MAMCOGsAe@MCI?MDIHIJWc@]g@OUOMMKQIQCSCUAg@?[AwAA{A?M?QAG?yC?{AAKGsC?kB?U?O?U?L`ADb@TzBPlCDrADtBElBQ|Bo@rEObAm@nDs@lCmDzJgBrDWj@M^K`@GZEXCXA`@@~A@X@R@\@R@X@ZJTFH@JL~ALhARvA?Rs@LSTGFGFEDE@eDfAKBMHEBC?E@GAk@DI@E?E?K@C?CAAACAA[?IS@u@FC?C?EAC?CAEACAc@UGCSICAERAH[~BAHCRATABCDCFCDGFIFGBEB]JEBG@IBs@JG@M@IAIAIIKG@V?XI|B?ZBp@^EF?`@Eb@Er@GJA??@?@E@QDg@Dc@MAwATK@',
    4: r's|txEe~atYfBbCDF{@~@QRSTKJPXBBHJPTp@t@xCbDTVJJd@h@xBbCTZR\FNBFFVDPBRDVBb@@^?ZADCf@Eb@_@dCAJGVM^Q^EJe@z@O\CV?BAH@J@JBHHNt@p@@RDLFLFHFFHDF@NFFBFDfDfC^XVNf@TfClBzChCvAfARNNHHDJDHBJBJ@J@H?J?J?JAHAJCJEJEJEpAw@NKPIPGRERETAT?TApG?hE?~EGhBCZ@V?TBXBVFVFVHTH^L`@PjLvE|CnAbC`AxDnAhC`ALDNBLBN@L@P?TAVCRETGpAg@TIVIVGTCPEZCVCd@Ch@AhBAhC?pGAxEAbD?n@?\?ZANCNARERGPGRIPINKNKPONQNQNUP[N]L_@L[Jc@No@~Mmn@t@sDF]F]D[B[Bu@@W?Y?[?[?[A[C_@E_@Ea@Ie@G_@I]Ke@Mc@M]s@yB]eAYcAQs@Oq@Os@Mq@Ie@G_@C_@Ec@Ca@Ac@Aa@Aa@?[@[@]BYDWDYF[FWHYHYJULWLWNWPURWTURSVSXU`BkAt@e@z@q@xBoBlAeAlAcAbBoA|@m@tA}@p@]LGTM`@f@`@d@^j@b@p@b@v@HPHPJVvDtIN`@KHIDSPkClBQLLV|BhFdAzBJVJT^z@KHA@g@^KAEIw@iBBOTSi@qACG@G@CFGHIdAzBJVPOfCmBVQWg@oAqCeB}DO[Q_@yDqIM]Pa@RQrB_BPO]u@}@kBYq@Yk@e@eAyEqKcFkLMYKSM[oJeTaNwZa@_AoAoCq@kBy@cC_ByEo@wA]w@i@uAs@sBmByEOk@gAkCi@yAm@mBQi@_@wAi@mBYiAk@aC_@{@}@kDoByHyAcHoCaMe@sBEQGQEOGOEOIQKOKOKMMKOMOIOIUISGSEO?[Ak@@yAF_L|@kh@bEcBPc@D]H[HSFOHUJYN[PYRa@ZyCtC}CxCqAnAkBlBu@p@m@f@c@Va@Ry@^cBt@q@ZiAj@aAh@{Az@g@Vi@X_@RWJc@Na@Je@Hi@DgAJgAFiAFm@Bs@?wIIeEG_A?S@S@[BSDQDo@Tq@Ve@NOFODUBKBQBQ@Q?M?M?MA[Cc@EiAOk@IQAQAU?U@I@I@IBSHGBIDGDIDIFIHIHIJGJILGJGNGNELERELCPUxB}@|Jk@hHI`Ak@nFM|@SbBO~@ADOfAId@Ib@K^K\KVIRKPILKNSRSPKHQJQJOFQFODo@L{AZgARSF]LSLULMHKJKJKNILGJSd@Wn@Wt@Y|@wAdEo@fBcC~HYdA_BdFMZQ^SXSVWVYV[VeBjAq@`@qAt@SJOFKBS@O@OAMCICICKEKGMKMOKQYm@KW{@yB]}@Yk@m@kAw@sAM[uAsBmDaFw@cAOQIIKKOMGEIEOGMEOEMASCO?O@O@MBQDSFOHoAt@ULSNOLQNMLMNOPMPc@l@_AvA]f@c@f@e@f@gA`AWTuAhAMJOHMFMFKBMBM@I@I?I?I?IAIAQAMCOGKCIGIGMIOOQSQUo@y@KKKIMIMGMEMEMCMAMAK?K@K?iDZm@Dm@@q@?qAEq@C_@Ea@G]G[GoA]c@M[Ma@QWM[QYQ]WYSOOe@c@{@{@e@e@c@a@]]e@a@_@YmDmCkBwAYS]U[QaHkDaAc@w@YgEmAcA[_Aa@_Aa@s@]q@_@qBqAmFiCeFcCeAcAw@e@IEUOSKCFkAzCiArCELGNCHCFELA^ANAHCCGGa@c@Y]u@s@c@a@UMIGsCaBKG[QKIMAK?i@AcBEO?kAEs@Co@AG?OAM?IAwB]GAmCe@KAMCCP?FOdAICc@IgAQCANoA@M}@Qo@Ke@GGCSEOCBOJQ@C@KHq@@ER{AJs@@IJq@D[PkAJq@Hs@Lw@@OFc@BOFYBKFO^u@nG}LRe@N]Zw@To@BGLUNa@N]Pa@L[HSl@uADIZs@Xo@FOFOTe@Xs@FKTk@FQDKDGBCBCFCFAFAL?T?T?n@ARGbAAfA?L?TANFHa@@MVcB@Q?O?SAWEcAA[C_@GaBCg@McDSuECQCQGQEOGKGGKKECCACCUKWMcAg@WMr@uAXm@@ANWTNNLj@`@RPFHBBJNJNFHHJHFBBFBJBLBZD\DHV@H@JBhAB`BFpC@LFbCF|C@L?RDnCDjC@b@?d@BlABfABx@BrA?T@NHnE@N?RH~D@b@@l@HhD?N@RBnB@T?J@TU?Sv@AFgAzCc@pAaAtCA@Uh@IPEJ{CpGS`@ADGVCHEZ?TCf@IlAInAAPCd@?DAFAJATQdCQrCANMCIAs@IIAk@G[Gc@Gg@GCLc@xBYS_AMM@C?SBuAL',
    5: r'oytxEytrsY}@VG?CCFQFOEMAKFE`Am@hAk@z@fFXjBPbALh@Hb@l@fCFVDTHXXnATlARfATjAH\?H?TZ@ZB`AH^BH@P?TAFl@O@M@I?KASA_@EkAM_@Ea@Cg@AqBIkDKQAi@Co@Aq@Eq@CmACkAA}DFM@Q?O?e@@m@@i@@e@?gEFG?C?w@BaCLi@D{BJ{@?cACwACO?u@AyBCoBCiBCaCEo@AaBAoCE_AEOCy@Ma@I}@YyA_@eAWm@Oe@Gi@GiAIYC_CScAIu@AY?[D[BWFUFOFKFQJUPCBUTg@h@WTc@`@yEpEy@p@]ZSNUR[VkBrAa@Xe@ZcCdBe@ZcA`A{AxAa@b@mAlAyB~B{@~@MJURURc@Xi@Vg@Ri@No@Jm@Do@@i@AYCe@Cc@Em@Iu@I_AKa@Eu@IqBUg@GEAeGq@q@Ii@GGA}ASuAQsAOyAO]EC`@MtCEd@I~AK~A?JK`BIdBIrAAZALANCZAZGx@IdBQvCE`CAN?J?vAAN@LFvE?r@BrA?V@R@~A@nA@l@@zA@z@@p@@x@@f@?h@@v@HzF@x@?H?`ABjB?t@@d@?R@d@O@S?eAGG?MAE?a@EyAIe@Ew@?G?_AFc@Hc@Jq@PGBuBf@C@MDA?E@IBe@LSDQFKBIDIBEBKFGDGDGFGFUTy@z@SRONa@`@IHOLGDWLWHKDIBOBKBK?qADaA@C?W@E?Q?K?E?cABY?g@@Q?e@@I?O@K?C?E?C?k@BmADG?M@O@SBOBO@SB]@U@I@I?g@BYBiAD]@a@Bu@DQ@S@q@Bk@D}BLy@BSA?^@h@?l@@h@J?fHKJA?O?YCeBA_@PAt@E`@C\AhAEXCf@CH?HATA\ARCNANCRCNALAF?lAEj@CB?D?B?J?NAH?d@AP?f@AX?bACD?J?P?D?VAB?`AApAEJ?JCNCHCJEVIVMFENMHI`@a@NORSx@{@TUFGFGFEFEJGDCHCHEJCPGREd@MHCDA@?LEBAtBg@FCp@Qb@Kb@I?M?Gp@m@LMjAmARSDELMNO\a@NUNULWZg@HMj@sAFKHGHAJ?Ak@CcBA_A?a@?UAq@AY?[AWC}BAcBCaAAoA?SAUAcBAyBCwB?K?M?wA?G?UDqCPgDP{C@OB]@MDy@JkBDm@JqB@GTeE@[FuADgA@c@?_@V@\DvD`@pCX`@DV@N@xARrANNBpBTH@TB~@LL@VDfANF@^DbAJl@FjANj@Fj@D`AAd@Ch@Ip@Ml@Sb@Sl@_@VSTSPQr@u@nBkBp@s@t@w@POzA_Bt@w@JMZYpCoBdAu@fBoA\YRQPOxAoAxFgFDEVWf@a@TUTSVSVOTIXIVGVCT?d@@t@B~AJh@DjAJvBLd@FbATjCr@z@T\Hb@Hd@FF@v@BdA@pAB~CFxBDzA@nA@^@~@@fABv@Bv@?J@r@@t@@l@@dAG`AGxCOz@AB?PAlAAx@AfBCR?VKdACBABC@EFgAByABo@PyBLiA@Q?Q@[AYC[TONMTSdA{@z@q@v@o@FEDEl@e@r@m@DCh@e@LI`@[FE`Am@hAk@DG\W`@WpBcAJGPSPUr@q@h@g@X[FIdA{ANWFGHIh@c@dBuAJILKd@_@HG@Al@a@FEDCl@s@HIRWFUBKZsAHWRGl@O^GT?T?l@HEFGFID_@N??@B@@r@r@TR}AtC[d@EDC@HvABf@lADdBJF@J?z@CPCNGTMt@_@NG`@S^k@JO\Wr@u@lAsAl@m@FGVKoAwFs@eDa@qBG]COe@iBAI_@NaAb@KDEBIBEBSBGBUH]FOB]DI@_@BG?E?]IOCGACICG?G?G@C@EDEDCNDNFRJF@F?RALAJCNCHEDCDEVQ@?BAB?B?B?B?D@H@D@FBB?D@D?BAHATIJC\QPIJGs@_D]}Ao@oCEe@CWO_CBa@Es@Ee@EWIm@Gw@?OGgFCkC?gAG{DAk@C_@[aHUuFEw@IgCAQEoAAOIaBCk@GwAIsBEcAEy@AOA[GoAQgDUoFKuBEgBKkBIaCMiFEqCAwBEk@I_AE_@Ea@MeAKu@Mq@Mq@_DoM{@eDQm@O_@GQaAaCiAsCqAqDgDmJaBeEkCkGkBwEoBqEa@w@e@y@yBmDk@_Ak@{@g@m@iAeAiAgAiBaBwAmAyAsAiAkAcCmC}BcC[[WYUWKQMOOWK[KWGYI[Ge@McAUyAQwAIg@Me@Oc@O_@QYS[WWuByB]]_@[e@]GC]?a@UYOwF_Da@WKIOMGEGEw@c@o@]k@]SKUOKKQMUg@EUEa@Ck@AO@]?YEs@Em@Ky@[cB]uAUmACMAE?EAG?E?G?G?O?G?E?C@EDWH[dCyH^kARo@BKBIJYbEgNViAJa@ZmADM?M@GACAEAEIIEEWImAYyCw@qHiBKE[GYEF]D[f@uD@GBWDUb@eDBMD_@F]VkB\iC@KFa@YIsEiAICICyA[E?E?KDg@XkAr@KHCDCHEXWBMEMCg@XCBc@VE@E@E?[GCACACC?CAC@GFe@@CBC@A?MLaADED?PDNFFFBF@F?LCJ?H@HBLPANEHAJ?F@LBDW@C@GDEDE^UzA}@JEHAH?zA\HB|ElAHBXF?Q?SLaAJ_@PqABSLiABMDm@[M_CqAYOaAk@OGw@c@{Ay@I@OCUMe@UWEWAc@UIEE?A?EDCD?D?BBBB@ZDB?B@@B?B?B?DABCDq@[c@S',
  };
}
