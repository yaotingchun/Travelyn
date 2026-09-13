import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

List<({double lat, double lng})> decodePolyline(String encoded) {
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

void main() {
  test('decodePolyline handles negative deltas properly without Web integer overflow', () {
    const day1 = r'oguxE_~usY[f@cB}AdAgCXq@r@aBQMgB}A{AwAqAiAmAgAKImAeA_@Wg@_@gA]OGa@UOI??A?g@`@sBfB_@VYNUL[H[H]DS@WBE`@OnAYrCAL?LAR?J@VBXFVR|@Nl@DPJb@\zAH\DLFXBN@F@F?PEd@Ef@ANCRCPOAMAWAU@QBG@SFa@L}An@c@PqBt@mAp@UPUNYPgAVWDk@LMDoBZu@NSBa@FcBZ]FODSFSH]PoAx@KHMFsAbAaAp@y@p@e@N]Ji@HU@_@?I?W?BVFh@PpB@LH`ABVDRPb@?Jb@j@b@Zr@\v@L?`@G~AERx@nAlAjAjAt@dAQz@UVItAe@~A_A`@WXQVOb@WN`@J`@B`@O`@AR?Z@d@ORAJO@kBLG@GY]k@c@]EQAGuAd@WH{@TeAPkAu@mAkAy@oADSF_B?a@w@Ms@]c@[c@k@?KQc@ESCWIaAAMQqBGi@CWAQX@H?T?ZCRATERGPGLGnA_Af@[`Aq@`@[LIJId@]^U\Ud@Qh@MPEDAh@ILCf@I^GTEt@O??v@Mx@OJCl@KBA|@OXKXSTMDPFVt@bC|@|ALRNRFJxBfDN`@d@lBJd@BPBLBFBFDBDBr@Rh@Td@RRFPFb@HNBPBdAP^FTBT?X?j@CN?L?N@B?p@Bb@DF?d@DR@Vt@Vr@BHHTWEGQ[_AGQMa@e@EG?c@Eu@COAM?O?k@BY?U?UC_@G]Gg@IQCOCc@IQGSGe@Si@Us@SECECI@MAQEyBg@GKQa@|@y@l@a@BAJId@lBJd@BPBLBFBFDBDBr@Rh@Td@RRFPFb@HNBPBdAP^FTBT?X?j@CN?L?N@t@Bb@DF?d@DR@Vt@Vr@BHHTZDl@HVBd@D`@D\BvGVb@@b@BrAJh@F|B`@ZD~@FPBzAJnBJH@\@NTHJHJJHLHDBDBF@FBD@F?L@rA?T?X@|CAR?L?H?P?jA?^@DUDg@nCFV?P?A\?X??AFAf@ALEv@AFABAL?LAL?J?PN?F@B@^FJ@LC`@a@RtARt@?@Xr@d@bA@Ah@WNg@@Il@iAVk@^y@JEl@UHERICOe@iBAIGSs@_D]}Ao@oCEe@CWO_CBa@Es@Ee@EWIm@Gw@?OGgFCkC?gAG{DAk@C_@[aHUuFEw@IgCAQEoAAOIaBCk@GwAIsBEcAEy@AOA[GoAQgDUoFKuBEgBKkBIaCMiFEqCAwBEk@I_AE_@Ea@MeAKu@Mq@Mq@_DoM{@eDQm@O_@GQaAaCiAsCqAqDgDmJaBeEkCkGkBwEoBqE[y@[aAGSEUCQAU?Y?W@QBQDOBMFKFKHKHIHEHEHCJCHAJALAH?fAFh@Fd@HdBX|B^|Dp@nDh@b@Fb@JZLd@Rf@XlBxAl@`@XLXLXJVFZFxARnAPTBR@N?LARCJCNCLEPEXK^OlDiBXOl@_@HIJINQJOJOBIDKDKDQBQD]De@b@_IBg@Dc@Fc@Hg@d@mCF_@F_@B]De@l@yOBe@Dc@DWDUFQFQJSHMJOJMLQNOt@k@TSPQPSPYNWHSFSFUF[F_@Di@VmE@c@@a@A_@CWCSEWGWGSIWa@iAIWIUEWEWAWAY?Y@YB[BYl@iG^yDF{@FiAFqAViGPyEDaAFkBBc@D_@D_@FYDSDOFOHOFMHKHKFGFEHEFEJELEJCLCNANAP?N@P@NBVFFBTFZLxElB`NtFhC`ALDNBLBN@L@P?TAVCRETGpAg@TIVIVGTCPEZCVCd@Ch@AhBAhC?pGAxEAbD?n@?\?ZANCNARERGPGRIPINKNKPONQNQNUP[N]L_@L[Jc@No@~Mmn@t@sDF]F]D[B[DY@[B]@]?_@?_@?]A]C]E]Ec@Ge@Ki@Ke@Ia@K_@Ka@qByHI]Sw@Mo@Os@Ko@Kq@Kw@K{@Is@Em@Eq@Cq@Ai@?i@?g@@c@@e@Bc@Di@Dg@Hk@Hg@He@Jc@Ng@Ng@Pg@Re@Te@Ve@Va@V_@Za@b@e@b@c@~BoBjCuBz@_Al@w@jAuA~@gAZ[TYPYNUHUJWFYDYB[@]?]A]C[EYI[K[KYK[eGiN_@eA]uAgByDuG}NoAsBo@sAs@yAsDyHYi@Wa@S[OUOQQQOMOGQIQGSCUCS?U@SBSBQFQHOHeFdDyG~EsGpEgDnCwHzFeFzDa@X]JyApAkA~@QNUP]i@MSsBmDiAkBOUTULP`E|GJP\n@UPSRsDhDwBxBg@h@gAbByApBkCpCeEdEkArAi@h@kBtAiAx@uAbAWTeAfAgAfAQRPRHLdClENTpCxEPVLTvBnDVb@PQ`@c@`CuBrBgBnYkV~EeE';
    final pts = decodePolyline(day1);
    expect(pts.length, greaterThan(800));
    expect(pts.first.lat, closeTo(35.667, 0.01));
    expect(pts.first.lng, closeTo(139.709, 0.01));
    expect(pts.last.lat, closeTo(35.645, 0.01));
    expect(pts.last.lng, closeTo(139.784, 0.01));

    // Verify all points are inside Tokyo area
    for (final pt in pts) {
      expect(pt.lat, inInclusiveRange(35.0, 36.0));
      expect(pt.lng, inInclusiveRange(139.0, 140.5));
    }
  });
}
