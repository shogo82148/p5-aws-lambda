#!/usr/local/bin/perl

#==================================================================
# 名称： WwwCount Ver3.16
# 作者： 杜甫々
# 最新版入手先： http://tohoho.wakusei.ne.jp/wwwsoft.htm
# 取り扱い： フリーソフト。利用/改造/再配布可能。確認メール不要。
# 著作権：Copyright (C) 1996-2018 杜甫々
#==================================================================

#==================================================================
# 使いかた：
#==================================================================
#   (書式1) wwwcount.cgi?test
#	CGIが使用できるかテストを行う。
#
#   (書式2) wwwcount.cgi?text
#	カウントアップを行い、カウンタをテキストで表示する。
#
#   (書式3) wwwcount.cgi?gif
#	カウントアップを行い、カウンタをGIFで表示する。
#
#   (書式4) wwwcount.cgi?hide+xxx.gif
#	カウントアップを行い、xxx.gifを表示する。

#==================================================================
# カスタマイズ：
#==================================================================

# ★ このファイルの 1行目の「#!/usr/local/bin/perl」を perl のパス
#    名にあわせて適切に書き換えてください。パス名が分らない場合は、
#    プロバイダやサーバー管理者に問い合わせてください。#! の前には
#    空行もスペース文字も入れないようにしてください。（必須）

# ★ Windows NT で IIS を使用する場合は、wwwcount.cgi がインストー
#    ルされているフォルダ名を 'C:/HomePage/cgi-bin' などのように指
#    定してください。（必須）
$chdir = '';

# ★ SSIのテキストモードで使用する場合は、$mode = "text"; としてく
#    ださい。（必須）
$mode = "";

# ★ CGIとしては動いているのに、wwwcount.cgi?test でテストできない
#    場合、下記の1行の先頭の # を削除してみてください。
#@ARGV = split(/\+/, $ENV{'QUERY_STRING'});

# ★ 表示桁数を例えば5桁に指定する場合は「$figure = 5;」のように指
#    定してください。0 を指定すると桁数自動調整になります。
$figure = 6;

# ★ ファイルロック機能をオンにする場合は 1 を、オフにする場合は 0
#    を指定してください。通常は 1 でよいでしょう。
$do_file_lock = 1;

# ★ 同アドレスチェック機能をオンにする場合は 1 を指定してください。
#    同じ日に同じ IP アドレスからのアクセスをカウントアップしなく
#    なります。
$do_address_check = 0;

# ★ レポート機能を使う場合は「$mailto = 'abc@xxx.yyy.zzz';」のよう
#    に自分のメールアドレスを設定してください。サーバーで sendmail
#    コマンドがサポートされている必要があります。
$mailto  = '';

# ★ レポート機能の送信元メールアドレス（通常は自分のアドレス）を
#    指定してください。省略時はカウンタ名になりますが、プロバイダ
#    によっては、送信元メールアドレスが適切なものかチェックしてい
#    るケースがあります。
$mailfrom = '';

# ★ レポート機能で、sendmail コマンドのパス名が /usr/lib/sendmail
#    と異なる場合は、適切に修正してください。
$sendmail = '/usr/lib/sendmail';

# ★ レポート機能で、詳細情報を添付せず、アクセス件数のみをレポー
#    トする場合は、0 を指定してください。
$account_detail = 1;

# ★ レポート機能で、アクセス元のホスト名を取得できない場合に、は、
#    この値を 1 に変更すると、IPアドレスからホスト名への変換を試み
#    るようになります。ホスト名変換は、サーバー負荷の原因にもなるの
#    でご注意ください。
$do_addr_to_host = 0;

# ★ レポート機能において、「$my_url = 'http://www.yyy.zzz/';」とす
#    ると、このアドレスにマッチするサイトからの FROM は表示しなくな
#    ります。
$my_url = '';

# ★ レポート機能で、%7E などのエンコード文字をデコードして記録する
#    場合は 1 を、そのまま記録する場合は 0 を指定してください。
$do_decode_url = 0;

# ★ 省略時のカウンター名を指定します。カウンター名は *.cnt や *.dat
#    などのファイル名に対応しています。
$count_name = "wwwcount";

#==================================================================
# 処理部：
#==================================================================

#
# カレントフォルダを変更する。
#
if ($chdir ne "") {
	chdir($chdir);
}

#
# 関連するファイルを洗い出しておく
#
$file_count  = "$count_name" . ".cnt";
$file_date   = "$count_name" . ".dat";
$file_access = "$count_name" . ".acc";
$file_lock   = "lock/$count_name" . ".loc";

#
# 引数を解釈する
#
@ARGV = split(/\+/, $ENV{'QUERY_STRING'});
for ($i = 0; $i <= $#ARGV; $i++) {
	if ($ARGV[$i] eq "test") {
		test();
	} elsif ($ARGV[$i] eq "text") {
		$mode = "text";
	} elsif ($ARGV[$i] eq "gif") {
		$mode = "gif";
	} elsif ($ARGV[$i] eq "hide") {
		$mode = "hide";
		$giffile = $ARGV[++$i];
		if (!($giffile =~ /\.gif$/i)) {
			exit(1);
		}
		if ($giffile =~ /[<>|&]/) {
			exit(1);
		}
	} elsif ($ARGV[$i] eq "name") {
		$count_name = $ARGV[++$i];
		if ($count_name !~ /^[a-zA-Z0-9]+$/) {
			exit(1);
		}
		$file_count  = "$count_name" . ".cnt";
		$file_date   = "$count_name" . ".dat";
		$file_access = "$count_name" . ".acc";
	} elsif ($ARGV[$i] eq "ref") {
		$reffile = $ARGV[++$i];
	}
}

#
# 環境変数TZを日本時間に設定する
#
$ENV{'TZ'} = "JST-9";

#
# ロック権を得る
#
if ($do_file_lock) {
	foreach $i ( 1, 2, 3, 4, 5, 6 ) {
		if (mkdir("$file_lock", 0755)) {
			# ロック成功。次の処理へ。
			last;
		} elsif ($i == 1) {
			# 10分以上古いロックファイルは削除する。
			($mtime) = (stat($file_lock))[9];
			if ($mtime < time() - 600) {
				rmdir($file_lock);
			}
		} elsif ($i < 6) {
			# ロック失敗。1秒待って再トライ。
			sleep(1);
		} else {
			# 何度やってもロック失敗。あきらめる。
			exit(1);
		}
	}
}

#
# 途中で終了してもロックファイルが残らないようにする
#
sub sigexit { rmdir($file_lock); exit(0); }
$SIG{'PIPE'} = $SIG{'INT'} = $SIG{'HUP'} = $SIG{'QUIT'} = $SIG{'TERM'} = "sigexit";

#
# カウンターファイルからカウンター値を読み出す。
#
if (open(IN, "< $file_count")) {
	$count = <IN>;
	close(IN);
} else {
	$count = -1;
}

#
# 日付ファイルから最終アクセス日付を読み出す。
#
if (open(IN, "< $file_date")) {
	$date_log = <IN>;
	close(IN);
} else {
	$date_log = "";
}

#
# 今日の日付を得る
#
($sec, $min, $hour, $mday, $mon, $year) = localtime(time());
$date_now = sprintf("%04d/%02d/%02d", 1900 + $year, $mon + 1, $mday);
$time_now = sprintf("%02d:%02d:%02d", $hour, $min, $sec);

#
# 日付が異なる、つまり、今日初めてのアクセスであれば
#
if ($date_log ne $date_now) {

	#
	# アクセスログをメールで送信する
	#
	if ($mailto ne "") {
		$tmp_count = 0;
		open(IN, "< $file_access");
		while (<IN>) {
			if (/^COUNT/) {
				$tmp_count++;
			}
		}
		close(IN);
		$msg = "";
		$msg .= "To: $mailto\n";
		if ($mailfrom eq "") {
			$msg .= "From: $count_name\n";
		} else {
			$msg .= "From: $mailfrom\n";
		}
		$msg .= "Subject: ACCESS $date_log $tmp_count\n";
		$msg .= "\n";
		if ($account_detail) {
			open(IN, "< $file_access");
			while (<IN>) {
				$msg .= $_;
			}
			close(IN);
		} else {
			$msg .= "Access = $tmp_count\n";
		}
		open(OUT, "| $sendmail $mailto");
		print OUT $msg;
		close(OUT);
	}

	#
	# アクセスログを初期化する
	#
	open(OUT, "> $file_access");
	close(OUT);

	#
	# 今日の日付を日付ログファイルに書き出す
	#
	open(OUT, "> $file_date");
	print(OUT "$date_now");
	close(OUT);
}

#
# すでに同アドレスからのアクセスがあればカウントアップしない
#
$count_up = 1;
if ($do_address_check) {
	open(IN, "$file_access");
	while (<IN>) {
		if ($_ eq "ADDR  = [ $ENV{'REMOTE_ADDR'} ]\n") {
			$count_up = 0;
			last;
		}
	}
	close(IN);
}

#
# カウントアップ処理
#
if (($count >= 0) && ($count_up == 1)) {

	#
	# カウンタをひとつインクリメントする
	#
	$count++;

	#
	# アクセスログを記録する
	#
	open(OUT, ">> $file_access");

	# カウント
	print(OUT "COUNT = [ $count ]\n");

	# 時刻
	print(OUT "TIME  = [ $time_now ]\n");

	# IPアドレス
	$addr = $ENV{'REMOTE_ADDR'};
	print(OUT "ADDR  = [ $addr ]\n");

	# ホスト名
	$host = $ENV{'REMOTE_HOST'};
	if ($do_addr_to_host && (($host eq "") || ($host eq $addr))) {
		$host = gethostbyaddr(pack("C4", split(/\./, $addr)), 2);
	}
	if (($host ne "") && ($host ne $addr)) {
		print(OUT "HOST  = [ $host ]\n");
	}

	# エージェント名
	print(OUT "AGENT = [ $ENV{'HTTP_USER_AGENT'} ]\n");

	# リンク元(SSI)
	$referer = $ENV{'HTTP_REFERER'};
	if (($mode eq "text") && ($referer ne "")) {
		if ($do_decode_url eq 1) {
			$referer =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("C", hex($1))/eg;
		}
		print(OUT "REFER = [ $referer ]\n");
	}

	# リンク元(CGI)
	$reffile =~ s/\\//g;
	if ($reffile && (!$my_url || ($reffile !~ /$my_url/))) {
		if ($do_decode_url eq 1) {
			$reffile =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("C", hex($1))/eg;
		}
		print(OUT "FROM  = [ $reffile ]\n");
	}

	print(OUT "\n");
	close(OUT);

	#
	# カウンタをカウンタファイルに書き戻す
	#
	if (open(OUT, "> $file_count")) {
		print(OUT "$count");
		close(OUT);
	}
}

#
# CGIスクリプトの結果としてカウンターを書き出す
#
if ($count == -1) {
	$count = 0;
}
if ($figure != 0) {
	$cntstr = sprintf(sprintf("%%0%dld", $figure), $count);
} else {
	$cntstr = sprintf("%ld", $count);
}
if ($mode eq "text") {
	printf("Content-type: text/html\n");
	printf("\n");
	printf("$cntstr\n");
} elsif ($mode eq "gif") {
	printf("Content-type: image/gif\n");
	printf("\n");
	@files = ();
	for ($i = 0; $i < length($cntstr); $i++) {
		$n = substr($cntstr, $i, 1);
		push(@files, "$n.gif");
	}
	require "./gifcat.pl";
	binmode(STDOUT);
	print &gifcat'gifcat(@files);
} elsif ($mode eq "hide") {
	printf("Content-type: image/gif\n");
	printf("\n");
	$size = -s $giffile;
	open(IN, $giffile);
	binmode(IN);
	binmode(STDOUT);
	read(IN, $buf, $size);
	print $buf;
	close(IN);
}

#
# ロック権を開放する
#
if ($do_file_lock) {
	rmdir($file_lock);
}

#
# CGIが使用できるかテストを行う。
#
sub test {
	print "Content-type: text/html\n";
	print "\n";
	print "<html>\n";
	print "<head>\n";
    print "<title>Test</title>\n";
    print "</head>\n";
	print "<body>\n";
	print "<p>OK. CGIスクリプトは正常に動いています。</p>\n";
	if ($mailto ne "") {
		if (! -f $sendmail) {
			print "<p>ERROR: $sendmail が存在しません。</p>\n";
		}
	}
	if (-d $file_lock) {
		print "<p>ERROR: $file_lock が残っています。</p>\n";
	}
	if (! -r $file_count) {
		print "<p>ERROR: $file_count が存在しません。</p>\n";
	} elsif (! -w $file_count) {
		print "<p>ERROR: $file_count が書き込み可能ではありません。</p>\n";
	}
	if (! -r $file_date) {
		print "<p>ERROR: $file_date が存在しません。</p>\n";
	} elsif (! -w $file_date) {
		print "<p>ERROR: $file_date が書き込み可能ではありません。</p>\n";
	}
	if (! -r $file_access) {
		print "<p>ERROR: $file_access が存在しません。</p>\n";
	} elsif (! -w $file_access) {
		print "<p>ERROR: $file_access が書き込み可能ではありません。</p>\n";
	}
	if (($chdir ne "") && (! -d $chdir)) {
		print "<p>ERROR: $chdir が存在しません。</p>\n";
	}
	print "</body>\n";
	print "</html>\n";
	exit(0);
}

