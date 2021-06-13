#!/usr/local/bin/perl

use strict;

#==================================================================
# 名称： WwwCount 4.0
# 作者： 杜甫々
# 最新版入手先： https://www.tohoho-web.com/wwwsoft.htm
# 取り扱い： フリーソフト。利用/改造/再配布可能。確認メール不要。
# 著作権：Copyright (C) 1996-2021 杜甫々
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
#
#   (オプション) wwwcount.cgi?(略)+name+counter2
#   複数カウンターを設置する場合にカウンター名を指定する。
#
#   (オプション) wwwcount.cgi?(略)+ref+xxxxxx
#   リンク元情報をカウンターに伝える

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
my $g_chdir = '';

# ★ SSIのテキストモードで使用する場合は、$g_mode = "text"; としてく
#    ださい。（必須）
my $g_mode = "";

# ★ 表示桁数を例えば5桁に指定する場合は「$g_figure = 5;」のように指
#    定してください。0 を指定すると桁数自動調整になります。
my $g_figure = 6;

# ★ ファイルロック機能をオンにする場合は 1 を、オフにする場合は 0
#    を指定してください。通常は 1 でよいでしょう。
my $g_lock_flag = 1;

# ★ 同アドレスチェック機能をオンにする場合は 1 を指定してください。
#    同じ日に同じ IP アドレスからのアクセスをカウントアップしなく
#    なります。
my $g_address_check = 0;

# ★ 省略時のカウンター名を指定します。カウンター名は *.cnt や *.dat
#    などのファイル名に対応しています。
my $g_counter_name = "wwwcount";

# ★ レポート機能を使う場合は「$g_mailto = 'admin@example.com';」の
#    ように自分のメールアドレスを設定してください。サーバーで
#    sendmailコマンドがサポートされている必要があります。
#    レポート機能を使用しない場合は空文字('')を指定してください。
my $g_mailto  = '';

# ★ レポート機能の送信元メールアドレス（通常は自分のアドレス）を
#    指定してください。省略時はカウンタ名になりますが、プロバイダ
#    によっては、送信元メールアドレスが適切なものかチェックしてい
#    るケースがあります。
my $g_mailfrom = 'admin <admin@example.com>';

# ★ レポート機能で、sendmail コマンドのパス名が /usr/lib/sendmail
#    と異なる場合は、適切に修正してください。
my $g_sendmail = '/usr/sbin/sendmail';

# ★ レポート機能で、詳細情報を添付せず、アクセス件数のみをレポー
#    トする場合は、0 を指定してください。
my $g_report_detail = 1;

# ★ レポート機能で、アクセス元のホスト名を取得できない場合に、は、
#    この値を 1 に変更すると、IPアドレスからホスト名への変換を試み
#    るようになります。ただし、ホスト名変換は、サーバー負荷の原因
#    になるのでご注意ください。
my $g_addr_to_host = 0;

# ★ レポート機能において、「$g_my_url = 'http://www.yyy.zzz/';」とす
#    ると、このアドレスにマッチするサイトからの FROM は表示しなくな
#    ります。
my $g_my_url = '';

# ★ レポート機能で、%7E などのエンコード文字をデコードして記録する
#    場合は 1 を、そのまま記録する場合は 0 を指定してください。
my $g_decode_url = 1;

my $count_dir = $ENV{WWWCOUNT_DIR} // ".";

# ★ ロックファイルを作成するフォルダ名を指定します。
my $g_lock_dir = "$count_dir/lock";

#==================================================================
# その他変数
#==================================================================

# 隠しカウンターで表示するGIFファイル名
my $g_gif_file = "";

# アクセス元情報
my $g_referer = "";

# カウンターファイル名(*.cnt)
my $g_file_count = "$count_dir/${g_counter_name}.cnt";

# 最終アクセス日記録ファイル名(*.dat)
my $g_file_date = "$count_dir/${g_counter_name}.dat";

# アクセス情報記録ファイル名(*.acc)
my $g_file_access = "$count_dir/${g_counter_name}.acc";

# ロックファイル名(*.loc)
my $g_file_lock = "${g_lock_dir}/${g_counter_name}.loc";

#==================================================================
# 処理部：
#==================================================================

#
# メインルーチン
#
{ 
	my($count, $last_access_date, $now_date, $now_time, $do_countup);

	# 環境変数TZを日本時間に設定する
	$ENV{'TZ'} = "JST-9";

	# カレントフォルダを変更する。
	if ($g_chdir ne "") {
		chdir($g_chdir);
	}

	# 引数を解釈する
	parseArguments();

	# テストモードであればテストを呼び出す
	if ($g_mode eq "test") {
		test();
		exit(0);
	}

	# ロックをかける
	doLock();

	# カウンターを読みだす
	$count = readCount();

	# 最終アクセス日を読みだす
	$last_access_date = readLastAccessDate();

	# 今日の日付と時刻を得る
	($now_date, $now_time) = getCurrentDateAndTime();

	# 日付が異なる、つまり、今日初めてのアクセスであれば
	if ($last_access_date ne $now_date) {

		# レポートメールを送信する
		sendReportMail($last_access_date);

		# アクセスログをクリアする
		clearAccessLog();

		# 今日の日付を日付ログファイルに書き出す
		saveLastAccessDate($now_date);
	}

	# 同一IPからのアクセスはカウントアップしないモードの場合、
	# カウントアップするか否かを確認する。
	$do_countup = checkCountup();

	# カウントアップする場合
	if ($do_countup) {

		# カウンターをインクリメントする
		$count++;

		# カウンターを記録する
		saveCount($count);

		# アクセスログを記録する
		saveAccessLog($count, $now_time);
	}

	# CGIの結果としてカウンターを書き出す
	outputCounter($count);

	# ロックを解放する
	unlockLock();
}

#
# 引数を解釈する
#
sub parseArguments {
	my(@argv) = split(/\+/, $ENV{'QUERY_STRING'});

	for (my $i = 0; $i <= $#argv; $i++) {
		# テストモード
		if ($argv[$i] eq "test") {
			$g_mode = "test";

		# テキストモード
		} elsif ($argv[$i] eq "text") {
			$g_mode = "text";

		# GIFモード
		} elsif ($argv[$i] eq "gif") {
			$g_mode = "gif";

		# 隠しカウンターモード
		} elsif ($argv[$i] eq "hide") {
			$g_mode = "hide";
			$g_gif_file = $argv[++$i];
			if (!($g_gif_file =~ /\.gif$/i)) {
				exit(1);
			}
			if ($g_gif_file =~ /[<>|&]/) {
				exit(1);
			}

		# カウンター名
		} elsif ($argv[$i] eq "name") {
			$g_counter_name = $argv[++$i];
			if ($g_counter_name !~ /^[a-zA-Z0-9]+$/) {
				exit(1);
			}
			$g_file_count  = "$g_counter_name" . ".cnt";
			$g_file_date   = "$g_counter_name" . ".dat";
			$g_file_access = "$g_counter_name" . ".acc";
			$g_file_lock   = "$g_lock_dir/$g_counter_name" . ".loc";

		# リンク元
		} elsif ($argv[$i] eq "ref") {
			$g_referer = $argv[++$i];
		}
	}
}

#
# カウンターファイルからカウンター値を読み出す。
#
sub readCount {
	my($count) = 0;
	local(*IN);

	if (open(IN, "< $g_file_count")) {
		$count = <IN>;
		close(IN);
	}
	return $count;
}

#
# カウンタをカウンタファイルに書き戻す
#
sub saveCount {
	my($count) = @_;

	if (open(OUT, "> $g_file_count")) {
		print(OUT "$count");
		close(OUT);
	}
}

#
# 日付ファイルから最終アクセス日付を読み出す。
#
sub readLastAccessDate {
	my $last_access_date;
	if (open(IN, "< $g_file_date")) {
		$last_access_date = <IN>;
		close(IN);
	} else {
		$last_access_date = "";
	}
	return $last_access_date;
}

#
# 今日の日付を日付ファイルに書き出す
#
sub saveLastAccessDate {
	my($now_date) = @_;

	open(OUT, "> $g_file_date");
	print(OUT "$now_date");
	close(OUT);
}

#
# 今日の日付を得る
#
sub getCurrentDateAndTime {
	my($sec, $min, $hour, $mday, $mon, $year) = localtime(time());
	my($now_date) = sprintf("%04d/%02d/%02d", 1900 + $year, $mon + 1, $mday);
	my($now_time) = sprintf("%02d:%02d:%02d", $hour, $min, $sec);
	return $now_date, $now_time;
}

#
# アクセスログを初期化する
#
sub clearAccessLog {
	open(OUT, "> $g_file_access");
	close(OUT);
}

#
# アクセスログを記録する
#
sub saveAccessLog {
	my($count, $now_time) = @_;
	my($addr, $host, $referer);
	local(*OUT);

	open(OUT, ">> $g_file_access");

	# カウント
	print(OUT "COUNT = [ $count ]\n");

	# 時刻
	print(OUT "TIME  = [ $now_time ]\n");

	# IPアドレス
	$addr = $ENV{'REMOTE_ADDR'};
	print(OUT "ADDR  = [ $addr ]\n");

	# ホスト名
	$host = $ENV{'REMOTE_HOST'};
	if ($g_addr_to_host && (($host eq "") || ($host eq $addr))) {
		$host = gethostbyaddr(pack("C4", split(/\./, $addr)), 2);
	}
	if (($host ne "") && ($host ne $addr)) {
		print(OUT "HOST  = [ $host ]\n");
	}

	# エージェント名
	print(OUT "AGENT = [ $ENV{'HTTP_USER_AGENT'} ]\n");

	# リンク元(SSI)
	$referer = $ENV{'HTTP_REFERER'};
	if (($g_mode eq "text") && ($referer ne "")) {
		if ($g_decode_url) {
			$referer =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("C", hex($1))/eg;
		}
		print(OUT "REFER = [ $referer ]\n");
	}

	# リンク元(CGI)
	$g_referer =~ s/\\//g;
	if ($g_referer && (!$g_my_url || ($g_referer !~ /$g_my_url/))) {
		if ($g_decode_url) {
			$g_referer =~ s/%([0-9a-fA-F][0-9a-fA-F])/pack("C", hex($1))/eg;
		}
		print(OUT "FROM  = [ $g_referer ]\n");
	}

	print(OUT "\n");
	close(OUT);
}

#
# アクセスログをメールで送信する
#
sub sendReportMail {
	my($last_access_date) = @_;
	my($access_count);
	local(*IN, *OUT);

	if ($g_mailto eq "") {
		return;
	}

	# アクセス件数を読み取る
	open(IN, "< $g_file_access");
	$access_count = 0;
	while (<IN>) {
		if (/^COUNT/) {
			$access_count++;
		}
	}
	close(IN);

	# レポートメールを送信する
	open(OUT, "| $g_sendmail -t -i");
	print OUT "To: $g_mailto\n";
	if ($g_mailfrom eq "") {
		print OUT "From: $g_counter_name\n";
	} else {
		print OUT "From: $g_mailfrom\n";
	}
	print OUT "Subject: ACCESS $last_access_date $access_count\n";
	print OUT "\n";
	if ($g_report_detail) {
		open(IN, "< $g_file_access");
		while (<IN>) {
			print OUT $_;
		}
		close(IN);
	} else {
		print OUT "Access = $access_count\n";
	}
	close(OUT);
}

#
# カウントアップするか否かを判断する
# すでに同アドレスからのアクセスがあればカウントアップしない
#
sub checkCountup {
	my($do_countup) = 1;
	local(*IN);

	if ($g_address_check) {
		open(IN, "$g_file_access");
		while (<IN>) {
			if ($_ eq "ADDR  = [ $ENV{'REMOTE_ADDR'} ]\n") {
				$do_countup = 0;
				last;
			}
		}
		close(IN);
	}
	return $do_countup;
}

#
# CGIスクリプトの結果としてカウンターを書き出す
#
sub outputCounter {
	my($count) = @_;
	my($count_str, @files, $size, $n, $buf);

	# カウンター文字列(例:000123)を得る
	if ($g_figure != 0) {
		$count_str = sprintf(sprintf("%%0%dld", $g_figure), $count);
	} else {
		$count_str = sprintf("%ld", $count);
	}

	# テキストモード
	if ($g_mode eq "text") {
		printf("Content-type: text/html\n");
		printf("\n");
		printf("$count_str\n");

	# GIFモード
	} elsif ($g_mode eq "gif") {
		printf("Content-type: image/gif\n");
		printf("\n");
		@files = ();
		for (my $i = 0; $i < length($count_str); $i++) {
			$n = substr($count_str, $i, 1);
			push(@files, "$n.gif");
		}
		require "./gifcat.pl";
		binmode(STDOUT);
		print gifcat'gifcat(@files);

	# 隠しカウンターモード
	} elsif ($g_mode eq "hide") {
		printf("Content-type: image/gif\n");
		printf("\n");
		$size = -s $g_gif_file;
		open(IN, $g_gif_file);
		binmode(IN);
		binmode(STDOUT);
		read(IN, $buf, $size);
		print $buf;
		close(IN);
	}
}

#
# ロックを得る
#
sub doLock {
	my($mtime);

	if ($g_lock_flag) {
		for (my $i = 1; $i <= 6; $i++) {
			if (mkdir("$g_file_lock", 0755)) {
				# ロック成功。次の処理へ。
				last;
			} elsif ($i == 1) {
				# 10分以上古いロックファイルは削除する。
				($mtime) = (stat($g_file_lock))[9];
				if ($mtime < time() - 600) {
					rmdir($g_file_lock);
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

	# 途中で終了してもロックファイルが残らないようにする
	sub sigexit { rmdir($g_file_lock); exit(0); }
	$SIG{'PIPE'} = $SIG{'INT'} = $SIG{'HUP'} = $SIG{'QUIT'} = $SIG{'TERM'} = "sigexit";
}

#
# ロックを開放する
#
sub unlockLock {
	if ($g_lock_flag) {
		rmdir($g_file_lock);
	}
}

#
# CGIが使用できるかテストを行う。
#
sub test {
	print "Content-type: text/html\n";
	print "\n";
	print "<!doctype html>\n";
	print "<html>\n";
	print "<head>\n";
	print "<meta charset='utf-8'>\n";
    print "<title>Test</title>\n";
    print "</head>\n";
	print "<body>\n";
	print "<p>OK. CGIスクリプトは正常に動いています。</p>\n";
	if ($g_mailto ne "") {
		if (! -f $g_sendmail) {
			print "<p>ERROR: $g_sendmail が存在しません。</p>\n";
		}
	}
	if (!-d $g_lock_dir) {
		print "<p>ERROR: $g_lock_dir フォルダがありません。</p>\n";
	}
	if (-d $g_file_lock) {
		print "<p>ERROR: $g_file_lock が残っています。</p>\n";
	}
	if (! -r $g_file_count) {
		print "<p>ERROR: $g_file_count が存在しません。</p>\n";
	} elsif (! -w $g_file_count) {
		print "<p>ERROR: $g_file_count が書き込み可能ではありません。</p>\n";
	}
	if (! -r $g_file_date) {
		print "<p>ERROR: $g_file_date が存在しません。</p>\n";
	} elsif (! -w $g_file_date) {
		print "<p>ERROR: $g_file_date が書き込み可能ではありません。</p>\n";
	}
	if (! -r $g_file_access) {
		print "<p>ERROR: $g_file_access が存在しません。</p>\n";
	} elsif (! -w $g_file_access) {
		print "<p>ERROR: $g_file_access が書き込み可能ではありません。</p>\n";
	}
	if (($g_chdir ne "") && (! -d $g_chdir)) {
		print "<p>ERROR: $g_chdir が存在しません。</p>\n";
	}
	print "</body>\n";
	print "</html>\n";
}
