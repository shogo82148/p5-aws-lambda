;# ====================================================================
;#
;# gifcat.pl: GIFファイル連結ライブラリ Ver1.61
;#
;# Copyright (c) 1997,2002 http://tohoho.wakusei.ne.jp/
;#
;# 著作権は放棄しませんが、自由に使用・改造・再配布可能です。
;#
;# 基本的な使い方
;#    require "gifcat.pl";
;#    open(OUT, "> out.gif");
;#    binmode(OUT);    # MS-DOS や Windows の場合に必要です。
;#    print OUT &gifcat'gifcat("xx.gif", "yy.gif", "zz.gif");
;#    close(OUT);
;#
;# デバッグ用(GIFの解析出力)
;#    require "gifcat.pl";
;#    &gifcat'gifprint("xx.gif", "yy.gif", "zz.gif");
;#
;# 制限事項
;#    アニメGIF同士を連結することはできません。
;#    アニメGIF対応のブラウザでなければ、最初の画像しか表示されません。
;#    高さの異なるGIFファイルは連結できません。
;#
;# 最新版入手先
;#    http://tohoho.wakusei.ne.jp/wwwsoft.htm
;#
;# 更新履歴:
;#    1997.05.03 初版。
;#    1997.05.10 スペルミス修正。
;#    1997.05.29 サイズの異なるカラーテーブルに対応。
;#    1997.07.07 エラー発生時にexit()しないように修正。
;#    1998.05.05 Trailerを持たないGIFファイルを連結できないバグを修正。
;#    1998.05.05 横幅が256を超えるGIFの出力ができないバグを修正。
;#    1998.05.05 gifprint()で連結結果を出力しないように修正。
;#    1998.05.10 連結できないGIF画像があるというバグを修正。
;#    1998.08.20 Ver1.50 変数の初期化を行うように修正。
;#    1998.08.20 Ver1.50 透過GIFに対応。
;#    1999.05.30 Ver1.51 動作には関係ないタイプミス修正。
;#    1999.10.11 Ver1.52 コメントの修正
;#    2000.05.21 Ver1.53 幅の異なるGIFの連結に対応
;#    2000.06.04 Ver1.54 perl -wcのwarning対応
;#    2000.06.04 Ver1.55 インタレースGIF部のコードミスを修正。
;#    2000.09.17 Ver1.56 連続呼び出しの際のバグ修正
;#    2000.11.28 Ver1.57 インタレースGIF部のコードミスを修正。
;#    2001.09.14 Ver1.58 gifcatを連続で呼び出す際の不具合修正。
;#    2001.10.04 Ver1.59 同上。
;#    2001.11.25 Ver1.60 gifprintの不具合修正。
;#    2002.06.10 Ver1.61 Netscape 6.*で1桁目が表示されない問題に対応。
;#
;# ====================================================================

package gifcat;

$pflag = 0;					# print flag

;# =====================================================
;# gifcat'gifprint() - print out GIF diagnostics.
;# =====================================================
sub gifprint {
	$pflag = 1;
	&gifcat(@_);
	$pflag = 0;
}

;# =====================================================
;# gifcat'gifcat() - get a concatenated GIF image.
;# =====================================================
sub gifcat {
	@files = @_;
	$Gif = 0;
	$leftpos = 0;
	$logicalScreenWidth = 0;
	$logicalScreenHeight = 0;
	$useLocalColorTable = 0;
	
	foreach $file (@files) {
		$size = -s $file;
		open(IN, "$file") || return("ERROR");
		binmode(IN);
		read(IN, $buf, $size) || return("ERROR");
		close(IN);

		$cnt = 0;
		&GifHeader();
		while (1) {
			$x1 = ord(substr($buf, $cnt, 1));
			if ($x1 == 0x2c) {
				&ImageBlock();
			} elsif ($x1 == 0x21) {
				$x2 = ord(substr($buf, $cnt + 1, 1));
				if ($x2 == 0xf9) {
					&GraphicControlExtension();
				} elsif ($x2 == 0xfe) {
					&CommentExtension();
				} elsif ($x2 == 0x01) {
					&PlainTextExtension();
				} elsif ($x2 == 0xff) {
					&ApplicationExtension();
				} else {
					return("ERROR");
				}
			} elsif ($x1 == 0x3b) {
				&Trailer();
				last;
			} elsif ($cnt == $size) {
				last;
			} else {
				return("ERROR");
			}
		}

		undef($buf);
		$Gif++;
	}
	if ($pflag == 1) {
		return;
	}

	$GifImage = "GIF89a";
	$GifImage .= pack("C", $logicalScreenWidth & 0x00ff);
	$GifImage .= pack("C", ($logicalScreenWidth & 0xff00) >> 8);
	$GifImage .= pack("C", $logicalScreenHeight & 0x00ff);
	$GifImage .= pack("C", ($logicalScreenHeight & 0xff00) >> 8);
	if ($useLocalColorTable) {
		$PackedFields18[0] &= ~0x80;
	}
	$GifImage .= pack("C", $PackedFields18[0]);
	$GifImage .= pack("C", $BackgroundColorIndex);
	$GifImage .= pack("C", $PixelAspectRatio);
	if ($useLocalColorTable == 0) {
		$GifImage .= $globalColorTable[0];
	}
	for ($i = -1; $i < $Gif; $i++) {
		$j = ($i == -1) ? 0 : $i;
		$GifImage .= pack("CCC", 0x21, 0xf9, 0x04);
		$GifImage .= pack("C", $PackedFields23 | $TransparentColorFlag[$j]);
		$GifImage .= pack("CC", 0x00, 0x00);
		$GifImage .= pack("C", $TransparentColorIndex[$j]);
		$GifImage .= pack("C", 0x00);
		$GifImage .= pack("C", 0x2c);
		$n = $leftpos;
		$leftpos += ($i == -1) ? 0 : $ImageWidth[$j];
		$GifImage .= pack("C", $n & 0x00ff);
		$GifImage .= pack("C", ($n & 0xff00) >> 8);
		$GifImage .= pack("CC", 0x00, 0x00);
		$GifImage .= pack("C", $ImageWidth[$j] & 0x00ff);
		$GifImage .= pack("C", ($ImageWidth[$j] & 0xff00) >> 8);
		$GifImage .= pack("C", $ImageHeight & 0x00ff);
		$GifImage .= pack("C", ($ImageHeight & 0xff00) >> 8);
		if ($useLocalColorTable) {
			$PackedFields20[$j] |= 0x80;
			$PackedFields20[$j] &= ~0x07;
			$PackedFields20[$j] |= ($PackedFields18[$j] & 0x07);
			$GifImage .= pack("C", $PackedFields20[$j]);
			$GifImage .= $globalColorTable[$j];
		} else {
			$GifImage .= pack("C", $PackedFields20[$j]);
		}
		$GifImage .= pack("C", $LzwMinimumCodeSize[$j]);
		$GifImage .= $ImageData[$j];
	}
	$GifImage .= pack("C", 0x3b);

}

;# =====================================
;# GifHeader
;# =====================================
sub GifHeader {
	$Signature = substr($buf, $cnt, 3); $cnt += 3;
	$Version   = substr($buf, $cnt, 3); $cnt += 3;
	$LogicalScreenWidth
			= ord(substr($buf, $cnt + 0, 1))
			+ ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$LogicalScreenHeight
			= ord(substr($buf, $cnt + 0, 1))
			+ ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$PackedFields18[$Gif]   = ord(substr($buf, $cnt, 1)); $cnt++;
	$GlobalColorTableFlag   = ($PackedFields18[$Gif] & 0x80) >> 7;
	$ColorResolution        = (($PackedFields18[$Gif] & 0x70) >> 4) + 1;
	$SortFlag               = ($PackedFields18[$Gif] & 0x08) >> 3;
	$SizeOfGlobalColorTable = 2 ** (($PackedFields18[$Gif] & 0x07) + 1);
	$BackgroundColorIndex   = ord(substr($buf, $cnt, 1)); $cnt++;
	$PixelAspectRatio       = ord(substr($buf, $cnt, 1)); $cnt++;
	if ($GlobalColorTableFlag) {
		$GlobalColorTable 
			= substr($buf, $cnt, $SizeOfGlobalColorTable * 3);
		$cnt += $SizeOfGlobalColorTable * 3;
	} else {
		$GlobalColorTable = "";
	}

	$logicalScreenWidth += $LogicalScreenWidth;
	if ($logicalScreenHeight < $LogicalScreenHeight) {
		$logicalScreenHeight = $LogicalScreenHeight;
	}
	if ($GlobalColorTableFlag) {
		$globalColorTable[$Gif] = $GlobalColorTable;
		if ($Gif > 0) {
			if ($GlobalColorTable ne $globalColorTable[$Gif - 1]) {
				$useLocalColorTable = 1;
			}
		}
	}

	if ($pflag) {
		printf("=====================================\n");
		printf("GifHeader\n");
		printf("=====================================\n");
		printf("Signature:                     %s\n", $Signature);
		printf("Version:                       %s\n", $Version);
		printf("Logical Screen Width:          %d\n", $LogicalScreenWidth);
		printf("Logical Screen Height:         %d\n", $LogicalScreenHeight);
		printf("Global Color Table Flag:       %d\n", $GlobalColorTableFlag);
		printf("Color Resolution:              %d\n", $ColorResolution);
		printf("Sort Flag:                     %d\n", $SortFlag);
		printf("Size of Global Color Table:    %d * 3\n", $SizeOfGlobalColorTable);
		printf("Background Color Index:        %d\n", $BackgroundColorIndex);
		printf("Pixel Aspect Ratio:            %d\n", $PixelAspectRatio);
		printf("Global Color Table:            \n");
		Dump($GlobalColorTable);
	}
}

;# =====================================
;# Image Block
;# =====================================
sub ImageBlock {
	$ImageSeparator    = ord(substr($buf, $cnt, 1)); $cnt++;
	$ImageLeftPosition = ord(substr($buf, $cnt, 1))
			   + ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$ImageTopPosition  = ord(substr($buf, $cnt, 1))
			   + ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$ImageWidth[$Gif]  = ord(substr($buf, $cnt, 1))
			   + ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$ImageHeight       = ord(substr($buf, $cnt, 1))
			   + ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$PackedFields20[$Gif]  = ord(substr($buf, $cnt, 1)); $cnt++;
	$LocalColorTableFlag   = ($PackedFields20[$Gif] & 0x80) >> 7;
	$InterlaceFlag         = ($PackedFields20[$Gif] & 0x40) >> 6;
	$SortFlag              = ($PackedFields20[$Gif] & 0x20) >> 5;
	$Reserved              = ($PackedFields20[$Gif] & 0x18) >> 3;
	if ($LocalColorTableFlag) {
		$SizeOfLocalColorTable = 2 ** (($PackedFields20[$Gif] & 0x07) + 1);
		$LocalColorTable = substr($buf, $cnt, $SizeOfLocalColorTable);
		$cnt += $SizeOfLocalColorTable * 3;
	} else {
		$SizeOfLocalColorTable = 0;
		$LocalColorTable = "";
	}
	$LzwMinimumCodeSize[$Gif] = ord(substr($buf, $cnt, 1)); $cnt++;
	$ImageData[$Gif] = &DataSubBlock();

	if ($pflag) {
		printf("=====================================\n");
		printf("Image Block\n");
		printf("=====================================\n");
		printf("Image Separator:               0x%02x\n", $ImageSeparator);
		printf("Image Left Position:           %d\n", $ImageLeftPosition);
		printf("Image Top Position:            %d\n", $ImageTopPosition);
		printf("Image Width:                   %d\n", $ImageWidth[$Gif]);
		printf("Image Height:                  %d\n", $ImageHeight);
		printf("Local Color Table Flag:        %d\n", $LocalColorTableFlag);
		printf("Interlace Flag:                %d\n", $InterlaceFlag);
		printf("Sort Flag:                     %d\n", $SortFlag);
		printf("Reserved:                      --\n");
		printf("Size of Local Color Table:     %d\n", $SizeOfLocalColorTable);
		printf("Local Color Table:             \n");
		Dump($LocalColorTable);
		printf("LZW Minimum Code Size:         %d\n", $LzwMinimumCodeSize[$Gif]);
		printf("Image Data:                    \n");
		Dump($ImageData[$Gif]);
		printf("Block Terminator:              0x00\n");
	}
}

;# =====================================
;# Graphic Control Extension
;# =====================================
sub GraphicControlExtension {
	$ExtensionIntroducer   = ord(substr($buf, $cnt, 1)); $cnt++;
	$GraphicControlLabel   = ord(substr($buf, $cnt, 1)); $cnt++;
	$BlockSize             = ord(substr($buf, $cnt, 1)); $cnt++;
	$PackedFields23        = ord(substr($buf, $cnt, 1)); $cnt++;
	$Reserved              = ($PackedFields23 & 0xe0) >> 5;
	$DisposalMethod        = ($PackedFields23 & 0x1c) >> 5;
	$UserInputFlag         = ($PackedFields23 & 0x02) >> 1;
	$TransparentColorFlag[$Gif]  = $PackedFields23 & 0x01;
	$DelayTime             = ord(substr($buf, $cnt, 1))
			       + ord(substr($buf, $cnt+1, 1)) * 256; $cnt += 2;
	$TransparentColorIndex[$Gif] = ord(substr($buf, $cnt, 1)); $cnt++;
	$BlockTerminator       = ord(substr($buf, $cnt, 1)); $cnt++;

	if ($pflag) {
		printf("=====================================\n");
		printf("Graphic Control Extension\n");
		printf("=====================================\n");
		printf("Extension Introducer:          0x%02x\n", $ExtensionIntroducer);
		printf("Graphic Control Label:         0x%02x\n", $GraphicControlLabel);
		printf("Block Size:                    %d\n", $BlockSize);
		printf("Reserved:                      --\n");
		printf("Disposal Method:               %d\n", $DisposalMethod);
		printf("User Input Flag:               %d\n", $UserInputFlag);
		printf("Transparent Color Flag:        %d\n", $TransparentColorFlag[$Gif]);
		printf("Delay Time:                    %d\n", $DelayTime);
		printf("Transparent Color Index:       %d\n", $TransparentColorIndex[$Gif]);
		printf("Block Terminator:              0x00\n");
	}
}

;# =====================================
;# Comment Extension
;# =====================================
sub CommentExtension {
	$ExtensionIntroducer   = ord(substr($buf, $cnt, 1)); $cnt++;
	$CommentLabel          = ord(substr($buf, $cnt, 1)); $cnt++;
	&DataSubBlock();

	if ($pflag) {
		printf("=====================================\n");
		printf("Comment Extension\n");
		printf("=====================================\n");
		printf("Extension Introducer:          0x%02x\n", $ExtensionIntroducer);
		printf("Comment Label:                 0x%02x\n", $CommentLabel);
		printf("Comment Data:                  ...\n");
		printf("Block Terminator:              0x%02x\n", $BlockTerminator);
	}
}

;# =====================================
;# Plain Text Extension
;# =====================================
sub PlainTextExtension {
	$ExtensionIntroducer  = ord(substr($buf, $cnt, 1)); $cnt++;
	$PlainTextLabel       = ord(substr($buf, $cnt, 1)); $cnt++;
	$BlockSize            = ord(substr($buf, $cnt, 1)); $cnt++;
	$TextGridLeftPosition = ord(substr($buf, $cnt, 1))
			      + ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$TextGridTopPosition  = ord(substr($buf, $cnt, 1))
			      + ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$TextGridWidth        = ord(substr($buf, $cnt, 1))
			      + ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$TextGridHeight       = ord(substr($buf, $cnt, 1))
			      + ord(substr($buf, $cnt + 1, 1)) * 256; $cnt += 2;
	$CharacterCellWidth   = ord(substr($buf, $cnt, 1)); $cnt++;
	$CharacterCellHeight  = ord(substr($buf, $cnt, 1)); $cnt++;
	$TextForegroundColorIndex = ord(substr($buf, $cnt, 1)); $cnt++;
	$TextBackgroundColorIndex = ord(substr($buf, $cnt, 1)); $cnt++;
	&DataSubBlock();

	if ($pflag) {
		printf("=====================================\n");
		printf("Plain Text Extension\n");
		printf("=====================================\n");
		printf("Extension Introducer:        0x%02x\n", $ExtensionIntroducer);
		printf("Plain Text Label:            0x%02x\n", $PlainTextLabel);
		printf("Block Size:                  0x%02x\n", $BlockSize);
		printf("Text Grid Left Position:     %d\n", $TextGridLeftPosition);
		printf("Text Grid Top Position:      %d\n", $TextGridTopPosition);
		printf("Text Grid Width:             %d\n", $TextGridWidth);
		printf("Text Grid Height:            %d\n", $TextGridHeight);
		printf("Text Foreground Color Index: %d\n", $TextForegroundColorIndex);
		printf("Text Background Color Index: %d\n", $TextBackgroundColorIndex);
		printf("Plain Text Data:             ...\n");
		printf("Block Terminator:            0x00\n");
	}
}

;# =====================================
;# Application Extension
;# =====================================
sub ApplicationExtension {
	$ExtensionIntroducer           = ord(substr($buf, $cnt, 1)); $cnt++;
	$ExtentionLabel                = ord(substr($buf, $cnt, 1)); $cnt++;
	$BlockSize                     = ord(substr($buf, $cnt, 1)); $cnt++;
	$ApplicationIdentifire         = substr($buf, $cnt, 8); $cnt += 8;
	$ApplicationAuthenticationCode = substr($buf, $cnt, 3); $cnt += 3;
	&DataSubBlock();

	if ($pflag) {
		printf("=====================================\n");
		printf("Application Extension\n");
		printf("=====================================\n");
		printf("Extension Introducer:          0x%02x\n",
			$ExtensionIntroducer);
		printf("Extension Label:               0x%02x\n",
			$PlainTextLabel);
		printf("Block Size:                    0x%02x\n",
			$BlockSize);
		printf("Application Identifire:        ...\n");
		printf("ApplicationAuthenticationCode: ...\n");
		printf("Block Terminator:              0x00\n");
	}
}

;# =====================================
;# Trailer
;# =====================================
sub Trailer {
	$cnt++;

	if ($pflag) {
		printf("=====================================\n");
		printf("Trailer\n");
		printf("=====================================\n");
		printf("Trailer:                       0x3b\n");
		printf("\n");
	}
}

;# =====================================
;# Data Sub Block
;# =====================================
sub DataSubBlock {
	local($n, $from);
	$from = $cnt;
	while ($n = ord(substr($buf, $cnt, 1))) {
		$cnt++;
		$cnt += $n;
	}
	$cnt++;
	return(substr($buf, $from, $cnt - $from));
}

;# =====================================
;# Memory Dump
;# =====================================
sub Dump {
	local($buf) = @_;
	my($i);

	if (length($buf) == 0) {
		return;
	}
	for ($i = 0; $i < length($buf); $i++) {
		if (($i % 16) == 0) {
			printf("  ");
		}
		printf("%02X ", ord(substr($buf, $i, 1)));
		if (($i % 16) == 15) {
			printf("\n");
		}
	}
	if (($i % 16) != 0) {
		printf("\n");
	}
}

1;

