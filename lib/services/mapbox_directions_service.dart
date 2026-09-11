import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
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
        final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
        final request = await client.getUrl(uri);
        final response = await request.close();
        if (response.statusCode == 200) {
          final body = await response.transform(utf8.decoder).join();
          final json = jsonDecode(body) as Map<String, dynamic>;
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

    // 2. Try OpenStreetMap OSRM public driving directions (Free, reliable, no key needed)
    try {
      final osrmUri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coordsParam'
        '?overview=full&geometries=polyline',
      );
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(osrmUri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
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

  /// Standard Google / Mapbox Polyline algorithm decoder
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
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add((lat: lat / 1E5, lng: lng / 1E5));
    }
    return points;
  }

  /// Precomputed real road network polylines from Mapbox Directions API for Days 1 through 5
  static final Map<int, String> _precomputedPolylines = {
    1: '}`wxEeetsYG@GY]k@c@]EQAGuAd@WH{@TeAPkAu@mAkAy@oADSF_B?a@w@Ms@]c@[c@k@?KQc@ESCWIaAAMQqBGi@CWAQX@H?T?ZCRATERGPGLGnA_Af@[`Aq@`@[LIJId@]^U\\Ud@Qh@MPEDAh@ILCf@I^GTEt@O??v@Mx@OJCl@KBA|@OXKXSTMDPFVt@bC|@|ALRNRFJxBfDN`@d@lBJd@BPBLBFBFDBDBr@Rh@Td@RRFPFb@HNBPBdAP^FTBT?X?j@CN?L?N@B?p@Bb@DF?d@DR@Vt@Vr@BHHTZDl@HVBd@D`@D\\BvGVb@@b@BrAJh@F|B`@ZD~@FPBzAJnBJH@\\@NTHJHJJHLHDBDBF@FBD@F?L@rA?T?X@|CAR?L?H?P?jA?^@DUDg@nCFV?P?A\\?X??AFAf@ALEv@AFABAL?LAL?J?PN?F@B@^FJ@LC`@a@RtARt@?@Xr@d@bA@Ah@WNg@@Il@iAVk@^y@JEl@UHERICOe@iBAIGSs@_D]}Ao@oCEe@CWO_CBa@Es@Ee@EWIm@Gw@?OGgFCkC?gAG{DAk@C_@[aHUuFEw@IgCAQEoAAOIaBCk@GwAIsBEcAEy@AOA[GoAQgDUoFKuBEgBKkBIaCMiFEqCAwBEk@I_AE_@Ea@MeAKu@Mq@Mq@_DoM{@eDQm@O_@GQaAaCiAsCqAqDgDmJaBeEkCkGkBwEoBqE[y@[aAGSEUCQAU?Y?W@QBQDOBMFKFKHKHIHEHEHCJCHAJALAH?fAFh@Fd@HdBX|B^|Dp@nDh@b@Fb@JZLd@Rf@XlBxAl@`@XLXLXJVFZFxARnAPTBR@N?LARCJCNCLEPEXK^OlDiBXOl@_@HIJINQJOJOBIDKDKDQBQD]De@b@_IBg@Dc@Fc@Hg@d@mCF_@F_@B]De@l@yOBe@Dc@DWDUFQFQJSHMJOJMLQNOt@k@TSPQPSPYNWHSFSFUF[F_@Di@VmE@c@@a@A_@CWCSEWGWGSIWa@iAIWIUEWEWAWAY?Y@YB[BYl@iG^yDF{@FiAFqAViGPyEDaAFkBBc@D_@D_@FYDSDOFOHOFMHKHKFGFEHEFEJELEJCLCNANAP?N@P@NBVFFBTFZLxElB`NtFhC`ALDNBLBN@L@P?TAVCRETGpAg@TIVIVGTCPEZCVCd@Ch@AhBAhC?pGAxEAbD?n@?\\?ZANCNARERGPGRIPINKNKPONQNQNUP[N]L_@L[Jc@No@~Mmn@t@sDF]F]D[B[DY@[B]@]?_@?_@?]A]C]E]Ec@Ge@Ki@Ke@Ia@K_@Ka@qByHI]Sw@Mo@Os@Ko@Kq@Kw@K{@Is@Em@Eq@Cq@Ai@?i@?g@@c@@e@Bc@Di@Dg@Hk@Hg@He@Jc@Ng@Ng@Pg@Re@Te@Ve@Va@V_@Za@b@e@b@c@~BoBjCuBz@_Al@w@jAuA~@gAZ[TYPYNUHUJWFYDYB[@]?]A]C[EYI[K[KYK[eGiN_@eA]uAgByDuG}NoAsBo@sAs@yAsDyHYi@Wa@S[OUOQQQOMOGQIQGSCUCS?U@SBSBQFQHOHeFdDyG~EsGpEgDnCwHzFeFzDa@X]JyApAkA~@QNUP]i@MSsBmD',
    2: 'mj~xEikbtYIDQF[RC@IDGDG@G@]FK@QD[BE@K?Q?EDAL@JHHFHDJ`AlBFFHAt@]HCDDDFzBwApAs@HGNIPKVMVOPINI`@SZM^KJCn@M~@O\\Gh@If@IHCDGBI@OBKDg@DUVH~@^PFRD\\FXD~@PtARTBn@HnAPZDXFZFrATLB@@NDLF^Px@`@TLXJvB~@NDdBHP@N?hAFZ@P@xBN\\BlBLT@N@T@bBJtAFhAHP?L@jAFtDPf@BF@^@VBt@BtBLH?F@L?N@n@D`ADB?f@DDa@@iA@}@?y@@K?OK?C?_BAGN?x@?J?P?j@A~@?L?R`ADB?f@DPDZHd@Nl@Pf@Nx@T|Ad@HBZJVH?XCx@?JA`@Ar@CdBAX?T@XBT@Fj@rBNj@FRJ^Nh@tAxE`@rAFTDLJl@TCL?n@HN@h@F\\FTBRBb@Ft@HvAPXD\\DbC^H@vBVN@TBxBTVB\\Dp@J`@F`AP\\Fn@JnARLBTDLBrBZ~AVF@PBJBPDpAVVFpCl@F@\\HTDVDxGnAFBXFZFxCp@J@`@JlAXZH`E|@tEdAxEjAHBTFVDZHvD|@jEhA~Ct@TFTJVJBBPJXX\\c@`@o@j@_A\\i@JO?AXc@HMb@w@JSh@aAFKLUXi@hAuBx@uAFKNWJOPYVc@^m@JQFKt@kA^g@@K?GCGc@c@',
    3: 'oosxE_~|sYHMBEXTBLRrA@TEl@?\\Hr@BNnAg@TKPIr@[nBgALKJIl@c@XQRITGl@QXG^GJAb@CXAT?CZARALIzBARO~DG|AALA^Cl@Gz@ALIj@GZe@fCk@dDSnAETCJ[dBAB?DEPCRWrDOxAAHCXGh@EV[dCAJCPCRYtBAHIn@ERUdBM|@Ih@Kj@AHGRQb@S^U^UZeAz@WN]LYFM?U@eDt@YD[JC@EHoA^[Pa@^SXQVKVGR[lAm@`CERFNDL@DRd@HCPGVIFAD?B?BB@B@F?DADC@KDa@JKBQTCDAD@BNr@F^JJ@FADCJKEOUEOMo@EYCSJ[BGBEDAFESe@AEEMGOkA~Ek@jAi@nAq@nAQZU\\WZUREDyBtByCvCgEjDGFKJYRq@NwBXe@H_ANqATg@HMB_Dh@eJpAE@G@UBm@@YESGe@UWUMMSUQWQQKIMGWMICICQAS@QDQHc@L]JcBf@]JWJe@LIDmAd@wClAKFKJIJIRGVM^KXOZMTKNCDKJKHUNSLmCjAgFtBYNYNaHzCc@PaE`Bg@R]N]NIB@VC^u@pKe@`HAXAJCJGHILEBGDEBKBM?I?MAMCOGsAe@MCI?MDIHIJWc@]g@OUOMMKQIQCSCUAg@?[AwAA{A?M?QAG?yC?{AAKGsC?kB?U?O?U?L`ADb@TzBPlCDrADtBElBQ|Bo@rE',
    4: 's|txEe~atYfBbCDF{@~@QRSTKJPXBBHJPTp@t@xCbDTVJJd@h@xBbCTZR\\FNBFFVDPBRDVBb@@^?ZADCf@Eb@_@dCAJGVM^Q^EJe@z@O\\CV?BAH@J@JBHHNt@p@@RDLFLFHFFHDF@NFFBFDfDfC^XVNf@TfClBzChCvAfARNNHHDJDHBJBJ@J@H?J?J?JAHAJCJEJEJEpAw@NKPIPGRERETAT?TApG?hE?~EGhBCZ@V?TBXBVFVFVHTH^L`@PjLvE|CnAbC`AxDnAhC`ALDNBLBN@L@P?TAVCRETGpAg@TIVIVGTCPEZCVCd@Ch@AhBAhC?pGAxEAbD?n@?\\?ZANCNARERGPGRIPINKNKPONQNQNUP[N]L_@L[Jc@No@~Mmn@t@sDF]F]D[B[Bu@@W?Y?[?[?[A[C_@E_@Ea@Ie@G_@I]Ke@Mc@M]s@yB]eAYcAQs@Oq@Os@Mq@Ie@G_@C_@Ec@Ca@Ac@Aa@Aa@?[@[@]BYDWDYF[FWHYHYJULWLWNWPURWTURSVSXU`BkAt@e@z@q@xBoBlAeAlAcAbBoA|@m@tA}@p@]LGTM`@f@`@d@^j@b@p@b@v@HPHPJVvDtIN`@KHIDSPkClBQLLV|BhFdAzBJVJT^z@KHA@g@^KAEIw@iBBOTSi@qACG@G@CFGHI}BiFMWPMjCmBRQQ_@yDqIM]Pa@RQrB_BPO]u@}@kBYq@Yk@e@eAyEqKcFkLMYKSM[oJeTaNwZa@_AoAoCq@kBy@cC_ByEo@wA]w@i@uAs@sBmByEOk@gAkCi@yAm@mBQi@_@wAi@mBYiAk@aC_@{@}@kDoByHyAcHoCaMe@sBEQGQEOGOEOIQKOKOKMMKOMOIOIUISGSEO?[Ak@@yAF_L|@kh@bEcBPc@D]H[HSFOHUJYN[PYRa@ZyCtC}CxCqAnAkBlBu@p@m@f@c@Va@Ry@^cBt@q@ZiAj@aAh@{Az@g@Vi@X_@RWJc@Na@Je@Hi@DgAJgAFiAFm@Bs@?wIIeEG_A?S@S@[BSDQDo@Tq@Ve@NOFODUBKBQBQ@Q?M?M?MA[Cc@EiAOk@IQAQAU?U@I@I@IBSHGBIDGDIDIFIHIHIJGJILGJGNGNELERELCPUxB}@|Jk@hHI`Ak@nFM|@SbBO~@ADOfAId@Ib@K^K\\KVIRKPILKNSRSPKHQJQJOFQFODo@L{AZgARSF]LSLULMHKJKJKNILGJSd@Wn@Wt@Y|@wAdEo@fBcC~HYdA_BdFMZQ^SXSVWVYV[VeBjAq@`@qAt@SJOFKBS@O@OAMCICICKEKGMKMOKQYm@KW{@yB]}@Yk@m@kAw@sAM[uAsBmDaFw@cAOQIIKKOMGEIEOGMEOEMASCO?O@O@MBQDSFOHoAt@ULSNOLQNMLMNOPMPc@l@_AvA]f@c@f@e@f@gA`AWTuAhAMJOHMFMFKBMBM@I@I?I?I?IAIAQAMCOGKCIGIGMIOOQSQUo@y@KKKIMIMGMEMEMCMAMAK?K@K?iDZm@Dm@@q@?qAEq@C_@Ea@G]G[GoA]c@M[Ma@QWM[QYQ]WYSOOe@c@{@{@e@e@c@a@]]e@a@_@YmDmCkBwAYS]U[QaHkDaAc@w@YgEmAcA[_Aa@_Aa@s@]q@_@qBqAmFiCeFcCeAcAw@e@IEUOSK`@_AKGGEEIEGS}A[cCUqBEUCUQyA_@qCAKCWAWAYAUEqCAS?OIgDAm@Ae@G}DAS?OKoEAWAOAuAAu@CiAAOA{@Ac@O@E@I?U@a@?M?c@@[?I?OFU?I?y@@uA@SGRGbAAfA?L?TANFHa@@MVcB@Q?O?SAWEcAA[C_@GaB',
    5: '}k}xEqimsYj@Ep@CRAPAt@E`@C\\AhAEXCf@CH?HATA\\ARCNANCRCNALAF?lAEj@CB?D?B?J?NAH?d@AP?f@AX?bACD?J?P?D?VAB?`AApAEJ?JCNCHCJEVIVMFENMHI`@a@NORSx@{@TUFGFGFEFEJGDCHCHEJCPGREd@MHCDA@?LEBAtBg@FCp@Qb@Kb@I?M?Gp@m@LMjAmARSDELMNO\\a@NUNULWZg@HMj@sAFKHGHAJ?Ak@CcBA_A?a@?UAq@AY?[AWC}BAcBCaAAoA?SAUAcBAyBCwB?K?M?wA?G?UDqCPgDP{C@OB]@MDy@JkBDm@JqB@GTeE@[FuADgA@c@?_@@_@B_@D_@D_@F_@NaATwABMBQN_AD_@F{@H_C@Y?[Jc@Be@He@DSDQHYRw@Nm@\\wALi@H_@z@iE`@oB@CNu@FKDGFAF@VJr@ZfAf@h@N`@Ff@DZAZCpDi@|AWVEPCVEfHgANCdHeAVETETE~Eu@dAWpEs@HA~AWTCFA\\EVBTJrBfDJNRXLSFMJIXURMd@Yd@WTMFCd@Sh@Yx@c@lBkAdAq@XQTOdBcA|@k@n@a@|@k@NIZSRMLGb@UBCFCFCD?D?D?XDLBlARXDr@PfAX~Ab@z@`@|@t@v@l@^Vb@Tn@\\h@X~Ax@FD^Rr@`@h@VVNLDZJXFRB@@`@DXBN@~Eh@XB`@D|Gr@pANNBL@d@D\\BV?ZA\\C\\E^ITGRKRIVEn@a@d@]v@k@?ATQGa@g@yCKq@Go@A[AYYiXQoNGu@Ge@G]Kc@}A{ESi@VDZDl@HVBd@D`@D\\BvGVb@@b@BrAJh@F|B`@ZD~@FPBzAJnBJH@\\@NTHJHJJHLHDBDBF@FBD@F?L@rA?T?X@|CAR?L?H?P?jA?^@V?\\F\\Fx@PD?FBb@J^?F@NBNDNFRJF@F?RALAJCNCHEDCDEVQ@?BAB?B?B?B?D@H@D@FBB?D@D?BAHATIJC\\QPIJGs@_D]}Ao@oCEe@CWO_CBa@Es@Ee@EWIm@Gw@?OGgFCkC?gAG{DAk@C_@[aHUuFEw@IgCAQEoAAOIaBCk@GwAIsBEcAEy@AOA[GoAQgDUoFKuBEgBKkBIaCMiFEqCAwBEk@I_AE_@Ea@MeAKu@Mq@Mq@_DoM{@eDQm@O_@GQaAaCiAsCqAqDgDmJaBeEkCkGkBwEoBqEa@w@e@y@yBmDk@_Ak@{@g@m@iAeAiAgAiBaBwAmAyAsAiAkAcCmC}BcC[[WYUWKQMOOWK[KWGYI[Ge@McAUyAQwAIg@Me@Oc@O_@QYS[WWuByB]]_@[e@]GC]?a@UYOwF_Da@WKIOMGEGEw@c@o@]k@]SKUOKKQMUg@EUEa@Ck@AO@]?YEs@Em@Ky@[cB]uAUmACMAE?EAG?E?G?G?O?G?E?C@EDWH[dCyH^kARo@BKBIJYbEgNViAJa@ZmADM?M@GACAEAEIIEEWImAYyCw@qHiBKE[GYEF]D[f@uD@GBWDUb@eDBMD_@F]VkB\\iC@KFa@YIsEiAICICyA[E?E?KDg@XkAr@KHCDCHEXWBMEMCg@XCBc@VE@E@E?[GCACACC?CAC@GFe@@CBC@A?MLaADE',
  };
}
