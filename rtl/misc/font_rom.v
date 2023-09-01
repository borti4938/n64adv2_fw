//////////////////////////////////////////////////////////////////////////////////
//
// This file is part of the N64 RGB/YPbPr DAC project.
//
// Copyright (C) 2015-2023 by Peter Bartmann <borti4938@gmail.com>
//
// N64 RGB/YPbPr DAC is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////////////////
//
// Company:  Circuit-Board.de
// Engineer: borti4938
//
// Module Name:    font_rom
// Project Name:   N64 Advanced RGB/YPbPr DAC Mod
// Target Devices: Max10, Cyclone IV and Cyclone 10 LP devices
// Tool versions:  Altera Quartus Prime
// Description:    simple line-multiplying
//
// Features: ip independent implementation of font rom
//
// This file is auto generated by script/font2rom.m
//
//////////////////////////////////////////////////////////////////////////////////


module font_rom(
  CLK,
  nRST,
  char_addr,
  char_line,
  rden,
  rddata
);

input       CLK;
input       nRST;
input [6:0] char_addr;
input [3:0] char_line;
input       rden;

output reg [7:0] rddata = 8'h0;


reg [10:0] addr_r = 11'h00;
reg        rden_r =  1'b0;

always @(posedge CLK or negedge nRST)
  if (!nRST) begin
    rddata <= 8'h0;
    addr_r <= 11'h00;
    rden_r <= 1'b0;
  end else begin
    addr_r <= {char_line,char_addr};
    rden_r <= rden;

    if (rden_r)
      case (addr_r)
        0094:    rddata <= 008;
        0096:    rddata <= 012;
        0138:    rddata <= 028;
        0144:    rddata <= 064;
        0145:    rddata <= 001;
        0148:    rddata <= 028;
        0161:    rddata <= 012;
        0168:    rddata <= 048;
        0169:    rddata <= 006;
        0176:    rddata <= 062;
        0177:    rddata <= 008;
        0178:    rddata <= 030;
        0179:    rddata <= 030;
        0180:    rddata <= 048;
        0181:    rddata <= 063;
        0182:    rddata <= 028;
        0183:    rddata <= 127;
        0184:    rddata <= 030;
        0185:    rddata <= 030;
        0188:    rddata <= 048;
        0190:    rddata <= 006;
        0191:    rddata <= 030;
        0192:    rddata <= 062;
        0193:    rddata <= 012;
        0194:    rddata <= 063;
        0195:    rddata <= 060;
        0196:    rddata <= 031;
        0197:    rddata <= 127;
        0198:    rddata <= 127;
        0199:    rddata <= 060;
        0200:    rddata <= 051;
        0201:    rddata <= 030;
        0202:    rddata <= 120;
        0203:    rddata <= 103;
        0204:    rddata <= 015;
        0205:    rddata <= 099;
        0206:    rddata <= 099;
        0207:    rddata <= 028;
        0208:    rddata <= 063;
        0209:    rddata <= 028;
        0210:    rddata <= 063;
        0211:    rddata <= 030;
        0212:    rddata <= 063;
        0213:    rddata <= 051;
        0214:    rddata <= 051;
        0215:    rddata <= 099;
        0216:    rddata <= 051;
        0217:    rddata <= 051;
        0218:    rddata <= 127;
        0219:    rddata <= 060;
        0221:    rddata <= 060;
        0222:    rddata <= 028;
        0224:    rddata <= 012;
        0226:    rddata <= 007;
        0228:    rddata <= 056;
        0230:    rddata <= 028;
        0232:    rddata <= 007;
        0233:    rddata <= 024;
        0234:    rddata <= 048;
        0235:    rddata <= 007;
        0236:    rddata <= 030;
        0266:    rddata <= 034;
        0272:    rddata <= 096;
        0273:    rddata <= 003;
        0276:    rddata <= 034;
        0289:    rddata <= 030;
        0296:    rddata <= 024;
        0297:    rddata <= 012;
        0303:    rddata <= 064;
        0304:    rddata <= 099;
        0305:    rddata <= 012;
        0306:    rddata <= 051;
        0307:    rddata <= 051;
        0308:    rddata <= 056;
        0309:    rddata <= 003;
        0310:    rddata <= 006;
        0311:    rddata <= 099;
        0312:    rddata <= 051;
        0313:    rddata <= 051;
        0316:    rddata <= 024;
        0318:    rddata <= 012;
        0319:    rddata <= 051;
        0320:    rddata <= 099;
        0321:    rddata <= 030;
        0322:    rddata <= 102;
        0323:    rddata <= 102;
        0324:    rddata <= 054;
        0325:    rddata <= 070;
        0326:    rddata <= 102;
        0327:    rddata <= 102;
        0328:    rddata <= 051;
        0329:    rddata <= 012;
        0330:    rddata <= 048;
        0331:    rddata <= 102;
        0332:    rddata <= 006;
        0333:    rddata <= 119;
        0334:    rddata <= 099;
        0335:    rddata <= 054;
        0336:    rddata <= 102;
        0337:    rddata <= 054;
        0338:    rddata <= 102;
        0339:    rddata <= 051;
        0340:    rddata <= 045;
        0341:    rddata <= 051;
        0342:    rddata <= 051;
        0343:    rddata <= 099;
        0344:    rddata <= 051;
        0345:    rddata <= 051;
        0346:    rddata <= 115;
        0347:    rddata <= 012;
        0348:    rddata <= 001;
        0349:    rddata <= 048;
        0350:    rddata <= 054;
        0352:    rddata <= 024;
        0354:    rddata <= 006;
        0356:    rddata <= 048;
        0358:    rddata <= 054;
        0360:    rddata <= 006;
        0361:    rddata <= 024;
        0362:    rddata <= 048;
        0363:    rddata <= 006;
        0364:    rddata <= 024;
        0372:    rddata <= 004;
        0394:    rddata <= 093;
        0397:    rddata <= 099;
        0400:    rddata <= 112;
        0401:    rddata <= 007;
        0404:    rddata <= 093;
        0410:    rddata <= 012;
        0411:    rddata <= 024;
        0417:    rddata <= 030;
        0421:    rddata <= 035;
        0424:    rddata <= 012;
        0425:    rddata <= 024;
        0426:    rddata <= 102;
        0427:    rddata <= 024;
        0431:    rddata <= 096;
        0432:    rddata <= 115;
        0433:    rddata <= 015;
        0434:    rddata <= 051;
        0435:    rddata <= 048;
        0436:    rddata <= 060;
        0437:    rddata <= 003;
        0438:    rddata <= 003;
        0439:    rddata <= 099;
        0440:    rddata <= 051;
        0441:    rddata <= 051;
        0442:    rddata <= 028;
        0443:    rddata <= 028;
        0444:    rddata <= 012;
        0446:    rddata <= 024;
        0447:    rddata <= 048;
        0448:    rddata <= 099;
        0449:    rddata <= 051;
        0450:    rddata <= 102;
        0451:    rddata <= 099;
        0452:    rddata <= 102;
        0453:    rddata <= 006;
        0454:    rddata <= 070;
        0455:    rddata <= 099;
        0456:    rddata <= 051;
        0457:    rddata <= 012;
        0458:    rddata <= 048;
        0459:    rddata <= 054;
        0460:    rddata <= 006;
        0461:    rddata <= 127;
        0462:    rddata <= 103;
        0463:    rddata <= 099;
        0464:    rddata <= 102;
        0465:    rddata <= 099;
        0466:    rddata <= 102;
        0467:    rddata <= 051;
        0468:    rddata <= 012;
        0469:    rddata <= 051;
        0470:    rddata <= 051;
        0471:    rddata <= 099;
        0472:    rddata <= 051;
        0473:    rddata <= 051;
        0474:    rddata <= 025;
        0475:    rddata <= 012;
        0476:    rddata <= 003;
        0477:    rddata <= 048;
        0478:    rddata <= 099;
        0482:    rddata <= 006;
        0484:    rddata <= 048;
        0486:    rddata <= 006;
        0488:    rddata <= 006;
        0491:    rddata <= 006;
        0492:    rddata <= 024;
        0500:    rddata <= 006;
        0522:    rddata <= 069;
        0525:    rddata <= 054;
        0528:    rddata <= 124;
        0529:    rddata <= 031;
        0532:    rddata <= 069;
        0538:    rddata <= 006;
        0539:    rddata <= 048;
        0545:    rddata <= 030;
        0549:    rddata <= 051;
        0552:    rddata <= 006;
        0553:    rddata <= 048;
        0554:    rddata <= 060;
        0555:    rddata <= 024;
        0559:    rddata <= 048;
        0560:    rddata <= 123;
        0561:    rddata <= 012;
        0562:    rddata <= 048;
        0563:    rddata <= 048;
        0564:    rddata <= 054;
        0565:    rddata <= 003;
        0566:    rddata <= 003;
        0567:    rddata <= 096;
        0568:    rddata <= 051;
        0569:    rddata <= 051;
        0570:    rddata <= 028;
        0571:    rddata <= 028;
        0572:    rddata <= 006;
        0573:    rddata <= 126;
        0574:    rddata <= 048;
        0575:    rddata <= 024;
        0576:    rddata <= 123;
        0577:    rddata <= 051;
        0578:    rddata <= 102;
        0579:    rddata <= 003;
        0580:    rddata <= 102;
        0581:    rddata <= 038;
        0582:    rddata <= 038;
        0583:    rddata <= 003;
        0584:    rddata <= 051;
        0585:    rddata <= 012;
        0586:    rddata <= 048;
        0587:    rddata <= 054;
        0588:    rddata <= 006;
        0589:    rddata <= 127;
        0590:    rddata <= 111;
        0591:    rddata <= 099;
        0592:    rddata <= 102;
        0593:    rddata <= 099;
        0594:    rddata <= 102;
        0595:    rddata <= 003;
        0596:    rddata <= 012;
        0597:    rddata <= 051;
        0598:    rddata <= 051;
        0599:    rddata <= 099;
        0600:    rddata <= 030;
        0601:    rddata <= 051;
        0602:    rddata <= 024;
        0603:    rddata <= 012;
        0604:    rddata <= 006;
        0605:    rddata <= 048;
        0609:    rddata <= 030;
        0610:    rddata <= 062;
        0611:    rddata <= 030;
        0612:    rddata <= 062;
        0613:    rddata <= 030;
        0614:    rddata <= 006;
        0615:    rddata <= 110;
        0616:    rddata <= 054;
        0617:    rddata <= 030;
        0618:    rddata <= 060;
        0619:    rddata <= 102;
        0620:    rddata <= 024;
        0621:    rddata <= 063;
        0622:    rddata <= 031;
        0623:    rddata <= 030;
        0624:    rddata <= 059;
        0625:    rddata <= 110;
        0626:    rddata <= 055;
        0627:    rddata <= 030;
        0628:    rddata <= 063;
        0629:    rddata <= 051;
        0630:    rddata <= 051;
        0631:    rddata <= 099;
        0632:    rddata <= 099;
        0633:    rddata <= 102;
        0634:    rddata <= 063;
        0650:    rddata <= 069;
        0653:    rddata <= 028;
        0656:    rddata <= 127;
        0657:    rddata <= 127;
        0660:    rddata <= 069;
        0666:    rddata <= 127;
        0667:    rddata <= 127;
        0673:    rddata <= 012;
        0677:    rddata <= 024;
        0680:    rddata <= 006;
        0681:    rddata <= 048;
        0682:    rddata <= 255;
        0683:    rddata <= 126;
        0685:    rddata <= 127;
        0687:    rddata <= 024;
        0688:    rddata <= 107;
        0689:    rddata <= 012;
        0690:    rddata <= 024;
        0691:    rddata <= 028;
        0692:    rddata <= 051;
        0693:    rddata <= 031;
        0694:    rddata <= 031;
        0695:    rddata <= 048;
        0696:    rddata <= 030;
        0697:    rddata <= 062;
        0700:    rddata <= 003;
        0702:    rddata <= 096;
        0703:    rddata <= 012;
        0704:    rddata <= 123;
        0705:    rddata <= 051;
        0706:    rddata <= 062;
        0707:    rddata <= 003;
        0708:    rddata <= 102;
        0709:    rddata <= 062;
        0710:    rddata <= 062;
        0711:    rddata <= 003;
        0712:    rddata <= 063;
        0713:    rddata <= 012;
        0714:    rddata <= 048;
        0715:    rddata <= 030;
        0716:    rddata <= 006;
        0717:    rddata <= 107;
        0718:    rddata <= 127;
        0719:    rddata <= 099;
        0720:    rddata <= 062;
        0721:    rddata <= 099;
        0722:    rddata <= 062;
        0723:    rddata <= 014;
        0724:    rddata <= 012;
        0725:    rddata <= 051;
        0726:    rddata <= 051;
        0727:    rddata <= 107;
        0728:    rddata <= 012;
        0729:    rddata <= 030;
        0730:    rddata <= 012;
        0731:    rddata <= 012;
        0732:    rddata <= 012;
        0733:    rddata <= 048;
        0737:    rddata <= 048;
        0738:    rddata <= 102;
        0739:    rddata <= 051;
        0740:    rddata <= 051;
        0741:    rddata <= 051;
        0742:    rddata <= 031;
        0743:    rddata <= 051;
        0744:    rddata <= 110;
        0745:    rddata <= 024;
        0746:    rddata <= 048;
        0747:    rddata <= 054;
        0748:    rddata <= 024;
        0749:    rddata <= 107;
        0750:    rddata <= 051;
        0751:    rddata <= 051;
        0752:    rddata <= 102;
        0753:    rddata <= 051;
        0754:    rddata <= 118;
        0755:    rddata <= 051;
        0756:    rddata <= 006;
        0757:    rddata <= 051;
        0758:    rddata <= 051;
        0759:    rddata <= 099;
        0760:    rddata <= 054;
        0761:    rddata <= 102;
        0762:    rddata <= 049;
        0778:    rddata <= 069;
        0781:    rddata <= 028;
        0784:    rddata <= 124;
        0785:    rddata <= 031;
        0788:    rddata <= 069;
        0794:    rddata <= 006;
        0795:    rddata <= 048;
        0801:    rddata <= 012;
        0805:    rddata <= 012;
        0808:    rddata <= 006;
        0809:    rddata <= 048;
        0810:    rddata <= 060;
        0811:    rddata <= 024;
        0815:    rddata <= 012;
        0816:    rddata <= 111;
        0817:    rddata <= 012;
        0818:    rddata <= 012;
        0819:    rddata <= 048;
        0820:    rddata <= 127;
        0821:    rddata <= 048;
        0822:    rddata <= 051;
        0823:    rddata <= 024;
        0824:    rddata <= 051;
        0825:    rddata <= 024;
        0828:    rddata <= 006;
        0829:    rddata <= 126;
        0830:    rddata <= 048;
        0831:    rddata <= 012;
        0832:    rddata <= 123;
        0833:    rddata <= 063;
        0834:    rddata <= 102;
        0835:    rddata <= 003;
        0836:    rddata <= 102;
        0837:    rddata <= 038;
        0838:    rddata <= 038;
        0839:    rddata <= 115;
        0840:    rddata <= 051;
        0841:    rddata <= 012;
        0842:    rddata <= 051;
        0843:    rddata <= 054;
        0844:    rddata <= 070;
        0845:    rddata <= 099;
        0846:    rddata <= 123;
        0847:    rddata <= 099;
        0848:    rddata <= 006;
        0849:    rddata <= 115;
        0850:    rddata <= 054;
        0851:    rddata <= 024;
        0852:    rddata <= 012;
        0853:    rddata <= 051;
        0854:    rddata <= 051;
        0855:    rddata <= 107;
        0856:    rddata <= 030;
        0857:    rddata <= 012;
        0858:    rddata <= 006;
        0859:    rddata <= 012;
        0860:    rddata <= 024;
        0861:    rddata <= 048;
        0865:    rddata <= 062;
        0866:    rddata <= 102;
        0867:    rddata <= 003;
        0868:    rddata <= 051;
        0869:    rddata <= 063;
        0870:    rddata <= 006;
        0871:    rddata <= 051;
        0872:    rddata <= 102;
        0873:    rddata <= 024;
        0874:    rddata <= 048;
        0875:    rddata <= 030;
        0876:    rddata <= 024;
        0877:    rddata <= 107;
        0878:    rddata <= 051;
        0879:    rddata <= 051;
        0880:    rddata <= 102;
        0881:    rddata <= 051;
        0882:    rddata <= 110;
        0883:    rddata <= 006;
        0884:    rddata <= 006;
        0885:    rddata <= 051;
        0886:    rddata <= 051;
        0887:    rddata <= 107;
        0888:    rddata <= 028;
        0889:    rddata <= 102;
        0890:    rddata <= 024;
        0906:    rddata <= 093;
        0909:    rddata <= 054;
        0912:    rddata <= 112;
        0913:    rddata <= 007;
        0916:    rddata <= 093;
        0922:    rddata <= 012;
        0923:    rddata <= 024;
        0933:    rddata <= 006;
        0936:    rddata <= 012;
        0937:    rddata <= 024;
        0938:    rddata <= 102;
        0939:    rddata <= 024;
        0943:    rddata <= 006;
        0944:    rddata <= 103;
        0945:    rddata <= 012;
        0946:    rddata <= 006;
        0947:    rddata <= 048;
        0948:    rddata <= 048;
        0949:    rddata <= 048;
        0950:    rddata <= 051;
        0951:    rddata <= 012;
        0952:    rddata <= 051;
        0953:    rddata <= 024;
        0954:    rddata <= 028;
        0955:    rddata <= 028;
        0956:    rddata <= 012;
        0958:    rddata <= 024;
        0960:    rddata <= 003;
        0961:    rddata <= 051;
        0962:    rddata <= 102;
        0963:    rddata <= 099;
        0964:    rddata <= 102;
        0965:    rddata <= 006;
        0966:    rddata <= 006;
        0967:    rddata <= 099;
        0968:    rddata <= 051;
        0969:    rddata <= 012;
        0970:    rddata <= 051;
        0971:    rddata <= 054;
        0972:    rddata <= 102;
        0973:    rddata <= 099;
        0974:    rddata <= 115;
        0975:    rddata <= 099;
        0976:    rddata <= 006;
        0977:    rddata <= 123;
        0978:    rddata <= 102;
        0979:    rddata <= 051;
        0980:    rddata <= 012;
        0981:    rddata <= 051;
        0982:    rddata <= 051;
        0983:    rddata <= 054;
        0984:    rddata <= 051;
        0985:    rddata <= 012;
        0986:    rddata <= 070;
        0987:    rddata <= 012;
        0988:    rddata <= 048;
        0989:    rddata <= 048;
        0993:    rddata <= 051;
        0994:    rddata <= 102;
        0995:    rddata <= 003;
        0996:    rddata <= 051;
        0997:    rddata <= 003;
        0998:    rddata <= 006;
        0999:    rddata <= 051;
        1000:    rddata <= 102;
        1001:    rddata <= 024;
        1002:    rddata <= 048;
        1003:    rddata <= 054;
        1004:    rddata <= 024;
        1005:    rddata <= 107;
        1006:    rddata <= 051;
        1007:    rddata <= 051;
        1008:    rddata <= 102;
        1009:    rddata <= 051;
        1010:    rddata <= 006;
        1011:    rddata <= 024;
        1012:    rddata <= 006;
        1013:    rddata <= 051;
        1014:    rddata <= 051;
        1015:    rddata <= 107;
        1016:    rddata <= 028;
        1017:    rddata <= 102;
        1018:    rddata <= 006;
        1034:    rddata <= 034;
        1037:    rddata <= 099;
        1040:    rddata <= 096;
        1041:    rddata <= 003;
        1044:    rddata <= 034;
        1057:    rddata <= 012;
        1061:    rddata <= 051;
        1064:    rddata <= 024;
        1065:    rddata <= 012;
        1068:    rddata <= 028;
        1070:    rddata <= 028;
        1071:    rddata <= 003;
        1072:    rddata <= 099;
        1073:    rddata <= 012;
        1074:    rddata <= 051;
        1075:    rddata <= 051;
        1076:    rddata <= 048;
        1077:    rddata <= 051;
        1078:    rddata <= 051;
        1079:    rddata <= 012;
        1080:    rddata <= 051;
        1081:    rddata <= 012;
        1082:    rddata <= 028;
        1083:    rddata <= 028;
        1084:    rddata <= 024;
        1086:    rddata <= 012;
        1087:    rddata <= 012;
        1088:    rddata <= 003;
        1089:    rddata <= 051;
        1090:    rddata <= 102;
        1091:    rddata <= 102;
        1092:    rddata <= 054;
        1093:    rddata <= 070;
        1094:    rddata <= 006;
        1095:    rddata <= 102;
        1096:    rddata <= 051;
        1097:    rddata <= 012;
        1098:    rddata <= 051;
        1099:    rddata <= 102;
        1100:    rddata <= 102;
        1101:    rddata <= 099;
        1102:    rddata <= 099;
        1103:    rddata <= 054;
        1104:    rddata <= 006;
        1105:    rddata <= 062;
        1106:    rddata <= 102;
        1107:    rddata <= 051;
        1108:    rddata <= 012;
        1109:    rddata <= 051;
        1110:    rddata <= 030;
        1111:    rddata <= 054;
        1112:    rddata <= 051;
        1113:    rddata <= 012;
        1114:    rddata <= 099;
        1115:    rddata <= 012;
        1116:    rddata <= 096;
        1117:    rddata <= 048;
        1121:    rddata <= 051;
        1122:    rddata <= 102;
        1123:    rddata <= 051;
        1124:    rddata <= 051;
        1125:    rddata <= 051;
        1126:    rddata <= 006;
        1127:    rddata <= 062;
        1128:    rddata <= 102;
        1129:    rddata <= 024;
        1130:    rddata <= 048;
        1131:    rddata <= 102;
        1132:    rddata <= 024;
        1133:    rddata <= 107;
        1134:    rddata <= 051;
        1135:    rddata <= 051;
        1136:    rddata <= 102;
        1137:    rddata <= 051;
        1138:    rddata <= 006;
        1139:    rddata <= 051;
        1140:    rddata <= 054;
        1141:    rddata <= 051;
        1142:    rddata <= 030;
        1143:    rddata <= 054;
        1144:    rddata <= 054;
        1145:    rddata <= 060;
        1146:    rddata <= 035;
        1162:    rddata <= 028;
        1168:    rddata <= 064;
        1169:    rddata <= 001;
        1172:    rddata <= 028;
        1185:    rddata <= 012;
        1189:    rddata <= 049;
        1192:    rddata <= 048;
        1193:    rddata <= 006;
        1196:    rddata <= 028;
        1198:    rddata <= 028;
        1199:    rddata <= 001;
        1200:    rddata <= 062;
        1201:    rddata <= 063;
        1202:    rddata <= 063;
        1203:    rddata <= 030;
        1204:    rddata <= 120;
        1205:    rddata <= 030;
        1206:    rddata <= 030;
        1207:    rddata <= 012;
        1208:    rddata <= 030;
        1209:    rddata <= 014;
        1211:    rddata <= 024;
        1212:    rddata <= 048;
        1214:    rddata <= 006;
        1215:    rddata <= 012;
        1216:    rddata <= 062;
        1217:    rddata <= 051;
        1218:    rddata <= 063;
        1219:    rddata <= 060;
        1220:    rddata <= 031;
        1221:    rddata <= 127;
        1222:    rddata <= 015;
        1223:    rddata <= 124;
        1224:    rddata <= 051;
        1225:    rddata <= 030;
        1226:    rddata <= 030;
        1227:    rddata <= 103;
        1228:    rddata <= 127;
        1229:    rddata <= 099;
        1230:    rddata <= 099;
        1231:    rddata <= 028;
        1232:    rddata <= 015;
        1233:    rddata <= 048;
        1234:    rddata <= 103;
        1235:    rddata <= 030;
        1236:    rddata <= 030;
        1237:    rddata <= 030;
        1238:    rddata <= 012;
        1239:    rddata <= 054;
        1240:    rddata <= 051;
        1241:    rddata <= 030;
        1242:    rddata <= 127;
        1243:    rddata <= 060;
        1244:    rddata <= 064;
        1245:    rddata <= 060;
        1249:    rddata <= 110;
        1250:    rddata <= 059;
        1251:    rddata <= 030;
        1252:    rddata <= 110;
        1253:    rddata <= 030;
        1254:    rddata <= 015;
        1255:    rddata <= 048;
        1256:    rddata <= 103;
        1257:    rddata <= 126;
        1258:    rddata <= 051;
        1259:    rddata <= 103;
        1260:    rddata <= 126;
        1261:    rddata <= 099;
        1262:    rddata <= 051;
        1263:    rddata <= 030;
        1264:    rddata <= 062;
        1265:    rddata <= 062;
        1266:    rddata <= 015;
        1267:    rddata <= 030;
        1268:    rddata <= 028;
        1269:    rddata <= 110;
        1270:    rddata <= 012;
        1271:    rddata <= 054;
        1272:    rddata <= 099;
        1273:    rddata <= 048;
        1274:    rddata <= 063;
        1324:    rddata <= 006;
        1339:    rddata <= 012;
        1361:    rddata <= 120;
        1383:    rddata <= 051;
        1386:    rddata <= 051;
        1392:    rddata <= 006;
        1393:    rddata <= 048;
        1401:    rddata <= 024;
        1511:    rddata <= 030;
        1514:    rddata <= 030;
        1520:    rddata <= 015;
        1521:    rddata <= 120;
        1529:    rddata <= 015;
        default: rddata <= 000;
    endcase
  end

endmodule
