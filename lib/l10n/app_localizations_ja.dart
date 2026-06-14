// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get settings => '設定';

  @override
  String get profile => 'プロフィール';

  @override
  String get preferences => '環境設定とアプリ';

  @override
  String get language => '言語';

  @override
  String get dataRetention => 'データ保持期間';

  @override
  String get permanentDataDeletion => '永久削除';

  @override
  String get oneMonth => '1ヶ月';

  @override
  String get threeMonths => '3ヶ月';

  @override
  String get sixMonths => '6ヶ月';

  @override
  String get oneYear => '1年';

  @override
  String get infinite => '無期限';

  @override
  String get driveBackup => 'Driveバックアップ';

  @override
  String get exportExcel => 'Excel書き出し';

  @override
  String get support => 'サポート';

  @override
  String get contact => 'お問い合わせ';

  @override
  String get about => '情報';

  @override
  String get aboutFinarcast =>
      'FinarcastはAI搭載の財務アシスタントです。支出を分析し、貯蓄目標の設定を支援し、財務の未来を最適化します。';

  @override
  String get comingSoon => 'この機能は間もなく公開されます！';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get save => '保存';

  @override
  String get close => '閉じる';

  @override
  String get ok => 'わかりました';

  @override
  String get error => 'エラー';

  @override
  String get home => 'ホーム';

  @override
  String get vaults => '金庫';

  @override
  String get analysis => '分析';

  @override
  String get totalBalance => '総残高';

  @override
  String get addNewVault => '新しい金庫を追加';

  @override
  String get addTransaction => '取引を追加';

  @override
  String get income => '収入';

  @override
  String get expense => '支出';

  @override
  String get amount => '金額';

  @override
  String get currency => '通貨';

  @override
  String get description => '内容';

  @override
  String get done => '完了';

  @override
  String get edit => '編集';

  @override
  String get mainVault => 'メインの金庫';

  @override
  String get newVault => '新しい金庫';

  @override
  String get all => 'すべて';

  @override
  String get allTime => '全期間';

  @override
  String get oneTime => '一回限り';

  @override
  String get weekly => '毎週';

  @override
  String get every2Weeks => '2週間ごと';

  @override
  String get every3Weeks => '3週間ごと';

  @override
  String get monthly => '毎月';

  @override
  String get every3Months => '3ヶ月ごと';

  @override
  String get every6Months => '6ヶ月ごと';

  @override
  String get yearly => '毎年';

  @override
  String get period => '期間';

  @override
  String get week => '週';

  @override
  String get month => '月';

  @override
  String get year => '年';

  @override
  String get targetDate => '目標日';

  @override
  String get category => 'カテゴリー';

  @override
  String get themeMode => 'テーマ';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get colorTheme => '色';

  @override
  String get food => '食費';

  @override
  String get cleaning => '掃除用品';

  @override
  String get grocery => '食料・雑貨';

  @override
  String get delivery => 'デリバリー';

  @override
  String get gas => 'ガス・燃料';

  @override
  String get duration => '終了までの期間';

  @override
  String get repeatsIndefinitely => '無期限に繰り返す';

  @override
  String get endsAfter => '回数で終了';

  @override
  String get minimum => '最小';

  @override
  String get maximum => '最大';

  @override
  String get dayOfWeek => '曜日';

  @override
  String get dayOfMonth => '毎月の日';

  @override
  String get dayOf => 'の日';

  @override
  String get dining => '外食';

  @override
  String get restaurant => 'レストラン';

  @override
  String get cafe => 'カフェ';

  @override
  String get rent => '家賃';

  @override
  String get office => 'オフィス';

  @override
  String get storage => '倉庫';

  @override
  String get bill => '公共料金';

  @override
  String get electricity => '電気';

  @override
  String get water => '水道';

  @override
  String get internet => 'ネット';

  @override
  String get phone => '携帯';

  @override
  String get cinema => '映画';

  @override
  String get concert => 'ライブ';

  @override
  String get game => 'ゲーム';

  @override
  String get event => 'イベント';

  @override
  String get subscription => 'サブスク';

  @override
  String get software => 'ソフト';

  @override
  String get gym => 'ジム';

  @override
  String get health => '健康';

  @override
  String get doctor => '病院';

  @override
  String get medicine => '薬';

  @override
  String get surgery => '手術';

  @override
  String get dentist => '歯科';

  @override
  String get taxi => 'タクシー';

  @override
  String get bus => 'バス';

  @override
  String get train => '電車';

  @override
  String get flight => '飛行機';

  @override
  String get fuel => 'ガソリン';

  @override
  String get shoes => '靴';

  @override
  String get course => '講座';

  @override
  String get book => '書籍';

  @override
  String get school => '学校';

  @override
  String get loan => 'ローン';

  @override
  String get credit => '借入れ';

  @override
  String get other => 'その他';

  @override
  String get balanceAdjustment => 'バランス調整';

  @override
  String balanceAdjustmentNote(Object newVal, Object oldVal) {
    return 'Vault のバランスが $oldVal から $newVal に調整されました。';
  }

  @override
  String get salary => '給与';

  @override
  String get bonus => 'ボーナス';

  @override
  String get dividend => '配当';

  @override
  String get freelance => 'フリーランス';

  @override
  String get commission => '歩合';

  @override
  String get stock => '株式';

  @override
  String get crypto => '暗号資産';

  @override
  String get interest => '利息';

  @override
  String get scholarship => '奨学金';

  @override
  String get sale => '売却';

  @override
  String get gift => 'お祝い・ギフト';

  @override
  String get cancel => 'キャンセル';

  @override
  String get everyDay => '毎日';

  @override
  String get everyWeek => '毎週';

  @override
  String get everyMonth => '毎月';

  @override
  String get day => '日';

  @override
  String get twoDays => '2日';

  @override
  String get threeDays => '3日';

  @override
  String get flexibleAmount => '柔軟な金額';

  @override
  String get monday => '月曜日';

  @override
  String get tuesday => '火曜日';

  @override
  String get wednesday => '水曜日';

  @override
  String get thursday => '木曜日';

  @override
  String get friday => '金曜日';

  @override
  String get saturday => '土曜日';

  @override
  String get sunday => '日曜日';

  @override
  String get january => '1月';

  @override
  String get february => '2月';

  @override
  String get march => '3月';

  @override
  String get april => '4月';

  @override
  String get may => '5月';

  @override
  String get june => '6月';

  @override
  String get july => '7月';

  @override
  String get august => '8月';

  @override
  String get september => '9月';

  @override
  String get october => '10月';

  @override
  String get november => '11月';

  @override
  String get december => '12月';

  @override
  String get selectDate => '日付を選択';

  @override
  String get allVaults => 'すべての金庫';

  @override
  String get items => '項目';

  @override
  String get expenses => '支出';

  @override
  String get incomes => '収入';

  @override
  String get currentBalance => '現在の残高';

  @override
  String get score => 'スコア';

  @override
  String get no => 'いいえ';

  @override
  String get vault => '金庫';

  @override
  String get vaultDetail => 'ボールトの詳細';

  @override
  String get vaultNameHint => '金庫名 (例: Savings)';

  @override
  String get initialBalance => '初期残高';

  @override
  String get createVault => 'ボールトの作成';

  @override
  String get transactions => 'トランザクション';

  @override
  String get manage => '管理';

  @override
  String get deleteVault => 'ボールトの削除';

  @override
  String deleteVaultConfirm(String name) {
    return '「 $name 」ボールトを削除してもよろしいですか?この操作は元に戻すことができません。';
  }

  @override
  String get gold => '金';

  @override
  String get amountNotEntered => '金額が入力されていません';

  @override
  String get addAmountByEditing => '編集して金額を追加する';

  @override
  String get added => '追加した';

  @override
  String get endDate => '終了日';

  @override
  String get occurred => '発生した';

  @override
  String get remainingCount => '残り数';

  @override
  String times(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 回',
      one: '1回',
    );
    return '$_temp0';
  }

  @override
  String get note => '注記';

  @override
  String get indefinitely => '無期限に';

  @override
  String dayOfMonthOrdinal(Object day) {
    return '月の$day日';
  }

  @override
  String get everyWeekDetailed => '毎週';

  @override
  String get everyMonthDetailed => '毎月';

  @override
  String get everyYearDetailed => '毎年';

  @override
  String get everyDayDetailed => '毎日';

  @override
  String get custom => 'カスタム';

  @override
  String get status => 'ステータス';

  @override
  String get pending => '保留中';

  @override
  String get removeFromVault => '金庫から外す';

  @override
  String get permanentDelete => '完全に削除';

  @override
  String get permanentDeleteDesc => 'この取引は完全に削除されます';

  @override
  String get yes => 'はい';

  @override
  String get minAmount => '最小';

  @override
  String get maxAmount => '最大';

  @override
  String get netBalance => '純残高';

  @override
  String get bestCase => 'ベストケース';

  @override
  String get worstCase => 'ワーストケース';

  @override
  String get selectCurrency => '通貨を選択';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get auto => 'オート';

  @override
  String get max => 'マックス';

  @override
  String get zero => '0';

  @override
  String get addCustomCategory => '新規追加';

  @override
  String get customCategoryHint => '例: スパイス、マーケット...';

  @override
  String get deleteCustomCategory => 'カテゴリを削除';

  @override
  String get deleteCustomCategoryConfirm => 'このカスタムカテゴリを削除してもよろしいですか？';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get library => '図書館';

  @override
  String get pageLabel => 'ページ';

  @override
  String get historyTitle => '取引履歴';

  @override
  String get radarTitle => '支出レーダー';

  @override
  String get giantsTitle => '浪費の巨人';

  @override
  String get dailyLimit => '1日の制限';

  @override
  String get spendableRemaining => '消耗品の残り';

  @override
  String get giantsWait => '支出の分配を待っています';

  @override
  String get weeklyShort => 'W';

  @override
  String get monthlyShort => 'M';

  @override
  String get yearlyShort => 'Y';

  @override
  String get newLabel => '新しい';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get tomorrow => '明日';

  @override
  String daysAgo(int count) {
    return '$count 日前';
  }

  @override
  String weeksAgo(int count) {
    return '$count 週間前';
  }

  @override
  String monthsAgo(int count) {
    return '$count か月前';
  }

  @override
  String get historyEmpty => 'まだ取引履歴がありません';

  @override
  String get upcomingPaymentsNotFound => '今後の支払いが見つかりません';

  @override
  String get transaction => '取引';

  @override
  String get membership => '会員権';

  @override
  String get restorePurchases => '購入を復元する';

  @override
  String get freePlan => '無料プラン';

  @override
  String get upgradeToPro => 'プレミアムにアップグレード';

  @override
  String get unlimitedVaults => '無制限の保管庫';

  @override
  String get active => 'アクティブ';

  @override
  String get inactive => '非アクティブ';

  @override
  String get notifications => '通知';

  @override
  String get disabled => '無効';

  @override
  String get monthlyNetBalance => '月次純残高';

  @override
  String get savingsRate => '貯蓄率';

  @override
  String get yearlyProjection => '年間予測';

  @override
  String get topExpense => '最高の費用';

  @override
  String get topIncome => '最高の収入';

  @override
  String get transactionBreakdown => 'トランザクションの内訳';

  @override
  String get incomeCount => '所得';

  @override
  String get expenseCount => '費用';

  @override
  String get scenarioAnalysis => 'シナリオ分析';

  @override
  String get monthlyBest => '月間ベスト';

  @override
  String get monthlyWorst => '月間最悪';

  @override
  String get yearlyBest => '年間ベスト';

  @override
  String get yearlyWorst => '年間最悪';

  @override
  String get perMonth => '/月';

  @override
  String itemCount(int count) {
    return '$count アイテム';
  }

  @override
  String get authEmailRequired => 'メールアドレスを入力してください。';

  @override
  String get authEmailInvalid => '有効なメールアドレスを入力してください。';

  @override
  String get authPasswordRequired => 'パスワードを入力してください。';

  @override
  String get authPasswordTooShort => 'パスワードは 6 文字以上である必要があります。';

  @override
  String get authConfirmPasswordRequired => 'パスワードを再入力してください。';

  @override
  String get authPasswordsDoNotMatch => '入力したパスワードが一致しません。';

  @override
  String get authUsernameRequired => 'ユーザー名を選択してください。';

  @override
  String get authUsernameTooShort => 'ユーザー名は少なくとも 3 文字である必要があります。';

  @override
  String get authUsernameInvalid => 'ユーザー名には文字、数字、アンダースコア (_) のみを含めることができます。';

  @override
  String get authUsernameTaken => 'このユーザー名はすでに使用されています。';

  @override
  String get authEmailNotConfirmed =>
      'あなたのメールアドレスはまだ認証されていません。メールに送信された確認コードを入力するか、新しいコードをリクエストしてください。';

  @override
  String get authInvalidCredentials => 'メールアドレスまたはパスワードが間違っています。';

  @override
  String get authEmailExists => 'このメール アドレスのアカウントはすでに存在します。';

  @override
  String get authWeakPassword => 'パスワードが弱すぎます。 6 文字以上のより強力なパスワードを入力してください。';

  @override
  String get authBadCode => '入力した確認コードが間違っているか、無効です。';

  @override
  String get authSignupDisabled => '現在、新規ユーザー登録は受け付けておりません。管理者にお問い合わせください。';

  @override
  String get authRateLimitExceeded =>
      '送信されたリクエストが多すぎます。メールの速度制限を超えました。しばらくしてからもう一度お試しください。';

  @override
  String get authOtpRequired => '6桁の認証コードを入力してください。';

  @override
  String get authOtpSent => '新しい確認コードがメールに送信されました。';

  @override
  String get authRegistrationSuccess => '登録が成功しました！メールに送信された確認コードを入力してください。';

  @override
  String get authVerificationCode => '検証コード';

  @override
  String authVerificationDesc(String email) {
    return '$email に送信された確認コードを入力して登録を完了します。';
  }

  @override
  String get authVerifyCode => 'コードの検証';

  @override
  String authResendCodeCountdown(int seconds) {
    return 'コードを再送信します ( $seconds 秒)';
  }

  @override
  String get authResendCode => 'コードを再送信する';

  @override
  String get authGoBack => '戻る';

  @override
  String get authWelcome => 'いらっしゃいませ';

  @override
  String get authLoginSubtitle => 'アカウントにログインして財務を管理しましょう。';

  @override
  String get authEmail => '電子メール';

  @override
  String get authPassword => 'パスワード';

  @override
  String get authForgotPassword => 'パスワードをお忘れですか';

  @override
  String get authLogin => 'サインイン';

  @override
  String get authOr => 'または';

  @override
  String get authGoogleSignIn => 'Google を続ける';

  @override
  String get authNewAccount => '新しいアカウント';

  @override
  String get authRegisterSubtitle => 'Finarcast の世界に参加して、自分の限界を設定してください。';

  @override
  String get authUsername => 'ユーザー名';

  @override
  String get authConfirmPassword => 'パスワードを認証する';

  @override
  String get authRegister => '今すぐ参加';

  @override
  String get authNoAccount => 'アカウントをお持ちでない場合は、';

  @override
  String get authAlreadyHaveAccount => 'すでにアカウントをお持ちですか?';

  @override
  String get authRegisterAction => 'サインアップ';

  @override
  String get authLoginAction => 'サインイン';

  @override
  String get authContinueAsGuest => 'ゲストとして続行';

  @override
  String get authPasswordReset => 'パスワードのリセット';

  @override
  String get authForgotPasswordDesc =>
      'メールアドレスを入力してパスワードをリセットしてください。 6桁の認証コードをお送りします。';

  @override
  String get authSendCode => 'コードを送信する';

  @override
  String get authBackToLogin => 'ログインに戻る';

  @override
  String get authVerificationCodeTitle => '検証コード';

  @override
  String authForgotPasswordOtpDesc(String email) {
    return '$email に送信された 6 桁の確認コードを入力します。';
  }

  @override
  String get authChangeEmail => 'メールアドレスの変更';

  @override
  String get authNewPasswordTitle => '新しいパスワード';

  @override
  String get authNewPasswordDesc => 'アカウントには少なくとも 6 文字の安全なパスワードを設定してください。';

  @override
  String get authNewPassword => '新しいパスワード';

  @override
  String get authConfirmNewPassword => '新しいパスワードの確認';

  @override
  String get authUpdatePassword => 'パスワードを更新する';

  @override
  String get authPasswordResetSuccess => 'パスワードが正常にリセットされ、サインインしました。';

  @override
  String get authGoogleError => 'Google サインイン エラー';

  @override
  String get authPasswordDifferentError => '新しいパスワードは現在のパスワードとは異なる必要があります。';

  @override
  String get authUserNotFoundError => 'このメール アドレスに登録されているユーザーは見つかりませんでした。';

  @override
  String get dataRetentionDetail =>
      'この期間を過ぎると、トランザクションはメイン リストから非表示になり、アーカイブに移動されます。アーカイブされたデータは残高に影響を与えず、ダッシュボードをクリーンな状態に保ちます。';

  @override
  String get retentionPeriodLabel => '保存期間:';

  @override
  String get premiumRequired => 'プレミアムが必要です';

  @override
  String get premiumRetentionDesc =>
      'データの保持、アーカイブ、および自動削除ルールは、プレミアム メンバーのみが利用できます。';

  @override
  String get premiumExportDesc =>
      'ExcelまたはCSV形式でのデータエクスポートは、プレミアムメンバーのみが利用できます。';

  @override
  String get later => '後で';

  @override
  String get permanentDeletionDetail =>
      '警告: この期間が経過すると、データはデバイスから完全に削除され、復元できなくなります。';

  @override
  String get purgePeriodLabel => '削除期間：';

  @override
  String get cloudSync => 'クラウド同期';

  @override
  String get loginRequiredLabel => 'ログインが必要です';

  @override
  String syncToday(String time) {
    return '今日の$time';
  }

  @override
  String syncYesterday(String time) {
    return '昨日の$time';
  }

  @override
  String get noSyncYet => '同期はまだ実行されていません';

  @override
  String get syncStatus => '同期ステータス';

  @override
  String lastSyncLabel(String time) {
    return '最終同期: $time';
  }

  @override
  String get syncBackgroundDesc => 'データはバックグラウンドでクラウドに自動的にバックアップされます。';

  @override
  String get syncCloudDesc =>
      'データは、Supabase クラウド インフラストラクチャを使用して即座にバックアップされます。アプリを削除してもログインすればデータを復元できます。';

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get syncing => 'データを同期中...';

  @override
  String syncPartialSuccess(String summary) {
    return '部分的に成功: $summary';
  }

  @override
  String syncFailed(String error) {
    return '同期に失敗しました。 $error';
  }

  @override
  String get syncConnectionError => 'インターネット接続またはログインの詳細を確認してください。';

  @override
  String get loginRequiredTitle => 'ログインが必要です';

  @override
  String get loginRequiredSyncDesc =>
      'データをバックアップするには、クラウド同期を有効にしてログインする必要があります。';

  @override
  String get premiumSyncDesc =>
      'クラウド同期機能は、Supabase バックアップ インフラストラクチャを使用しており、プレミアム メンバーのみが利用できます。';

  @override
  String get showOnPhone => '電話で表示する';

  @override
  String get appOnly => 'アプリのみ';

  @override
  String get notificationDesc =>
      'リマインダーをアプリ内のみに保持するか、携帯電話の通知パネルにも表示するかを決定します。オフにすると、リマインダーはアプリ内に静かに残ります。';

  @override
  String get selectMainCurrency => 'メインアプリケーションの通貨を選択します。';

  @override
  String get currencyDesc =>
      'この通貨は、アプリ (ダッシュボード、ボールト、統計) 全体で主要通貨として使用されます。すべての資産はこの通貨に基づいて計算されます。';

  @override
  String get changeCurrency => '通貨の変更';

  @override
  String get exchangeRateNotFoundError =>
      '選択した通貨の為替レートが見つかりません。インターネット接続を確認して、もう一度試してください。';

  @override
  String get exchangeRatesDownloadFailed =>
      '為替レートをダウンロードできませんでした。インターネット接続を確認してください。';

  @override
  String get exchangeRatesCheckError => '料金の確認中にエラーが発生しました。もう一度試してください。';

  @override
  String get exchangeRates => '為替レート';

  @override
  String get baseUnitLira => '基本単位: トルコ リラ';

  @override
  String baseUnitLabel(String currency) {
    return 'ベースユニット: $currency';
  }

  @override
  String lastSyncShort(String time) {
    return '最後: $time';
  }

  @override
  String get updateRatesNow => '今すぐ料金を更新';

  @override
  String get updatingRates => '更新中...';

  @override
  String get exchangeRatesUpdated => '為替レートが正常に更新されました。';

  @override
  String get exchangeRatesUpdateFailed => 'アップデートに失敗しました。インターネット接続を確認してください。';

  @override
  String get showLess => '表示を減らす';

  @override
  String get showMore => 'もっと見る';

  @override
  String get styleLabel => 'スタイル';

  @override
  String get styleDesc => 'カードと背景のビジュアル スタイルを選択します';

  @override
  String get styleColor => '色付き';

  @override
  String get styleColorDesc => '調和のとれた色';

  @override
  String get styleSimple => '単純';

  @override
  String get styleSimpleDesc => 'フラットなデザイン';

  @override
  String get premiumStyleDesc => 'カラースタイルはプレミアム会員のみご利用いただけます。';

  @override
  String get premiumColorDesc =>
      'カスタム カラー テーマと高度なグラデーションは、プレミアム メンバーのみが利用できます。';

  @override
  String get paletteArctic => '北極';

  @override
  String get paletteMint => 'ミント';

  @override
  String get paletteRose => '薔薇';

  @override
  String get paletteLavender => 'ラベンダー';

  @override
  String get paletteSahara => 'サハラ';

  @override
  String get paletteSapphire => 'サファイア';

  @override
  String get paletteBurgundy => 'ブルゴーニュ';

  @override
  String get palettePlatinum => '白金';

  @override
  String get yearlyDiscount => '年間 (-33%)';

  @override
  String get comparisonTitle => '比較';

  @override
  String get limitVaults => 'ボールト制限';

  @override
  String get limitAiAnalysis => 'AIトランザクションアシスタント';

  @override
  String get limitCloudSync => 'クラウド同期';

  @override
  String get limitDataRetention => 'データの保持とパージ';

  @override
  String get limitCustomThemes => 'カスタムテーマ';

  @override
  String get limitAdFree => '広告なしのエクスペリエンス';

  @override
  String get limitVaultsFree => '2 つの保管庫';

  @override
  String get limitVaultsPro => '無制限';

  @override
  String get basicAnalysis => '標準';

  @override
  String get advancedAnalysis => '拡張された';

  @override
  String get limitDataRetentionPro => 'カスタマイズ可能';

  @override
  String get cancelSubscriptionTest => 'サブスクリプションのキャンセル (テスト)';

  @override
  String get yearlyAccess => '年間アクセス';

  @override
  String get monthlyAccess => '月間アクセス数';

  @override
  String get yearlyPriceDetail => '費用 ₺99/月';

  @override
  String get monthlyPriceDetail => '毎月更新';

  @override
  String get loginRequiredPurchaseDesc => '購入を完了するには、ログインするか無料アカウントを作成してください。';

  @override
  String get loginOrRegister => 'ログイン/登録';

  @override
  String get privilegesActive => '権限が有効です';

  @override
  String get tapToUnlock => 'タップして制限を解除します';

  @override
  String get sectionMembershipAccount => 'メンバーシップとアカウント';

  @override
  String get sectionAppearanceStyle => '外観とスタイル';

  @override
  String get sectionDataCloud => 'データとクラウド';

  @override
  String get sectionSessionSecurity => 'セッションとセキュリティ';

  @override
  String get guestUser => 'ゲストユーザー';

  @override
  String get tapToLogin => 'タップしてログインまたは登録します';

  @override
  String get changePassword => 'パスワードを変更する';

  @override
  String get changePasswordDesc =>
      '現在のパスワードを確認して新しいパスワードを設定します。パスワードは 6 文字以上である必要があります。';

  @override
  String get currentPasswordHint => '現在のパスワード';

  @override
  String get newPasswordHint => '新しいパスワード';

  @override
  String get confirmNewPasswordHint => '新しいパスワードの確認';

  @override
  String get currentPasswordRequired => '現在のパスワードを入力する必要があります。';

  @override
  String get updatePassword => 'パスワードを更新する';

  @override
  String get signOut => 'サインアウト';

  @override
  String get logout => 'ログアウト';

  @override
  String get logoutConfirm => 'ログアウトしてもよろしいですか?';

  @override
  String get deleteAccount => 'アカウントの削除';

  @override
  String get deleteAccountPermanently => 'アカウントを完全に削除';

  @override
  String get deleteAccountConfirmDesc =>
      'アカウントとクラウド内のすべてのデータを完全に削除してもよろしいですか?この操作は元に戻すことができません。';

  @override
  String get reset => 'リセット';

  @override
  String get resetDataTitle => 'データをリセットしますか?';

  @override
  String get resetDataDesc => 'すべての財務データと設定は完全に削除されます。この操作は元に戻すことができません。';

  @override
  String get resetCloudBackup => 'クラウドバックアップも削除する (Supabase)';

  @override
  String get resetOnlyDevice => 'このデバイスのみをリセット';

  @override
  String get resetDeviceAndCloud => 'デバイスとクラウドをリセット';

  @override
  String get deleteAll => 'すべて削除';

  @override
  String get resetSuccess => 'すべてのデータと設定が正常にリセットされました。';

  @override
  String get noTransactionsToExport => 'エクスポートする取引履歴が見つかりませんでした。';

  @override
  String get supportEmailCopied =>
      '電子メール クライアントを開けませんでした。サポート電子メール (finarcast.support@gmail.com) がコピーされました。';

  @override
  String get signInMethod => 'サインイン方法';

  @override
  String errorGeneric(Object error) {
    return 'エラー: $error';
  }

  @override
  String resetFailed(Object error) {
    return 'リセットに失敗しました: $error';
  }

  @override
  String get criticalDatabaseError => '重大なデータベースエラー';

  @override
  String get criticalDatabaseErrorDesc =>
      'アプリケーション データベースで読み取り不能または破損したデータが検出されました。下のボタンをクリックすると、データベースをクリーンアップしてアプリケーションを最初から再起動できます。';

  @override
  String get resetDatabaseAndRestart => 'データベースをリセットして再起動する';

  @override
  String get errorDetail => 'エラーの詳細:';

  @override
  String get unlimitedAccessLimit => '無制限のアクセス制限';

  @override
  String get unlimitedAccessLimitDesc =>
      'システム セキュリティのフェアユース制限に達しました。後でもう一度試すか、サポートにお問い合わせください。';

  @override
  String get standardAccessLimit => '標準アクセス制限';

  @override
  String get standardAccessLimitDesc =>
      '1 日あたりの標準 AI 分析割り当てに達しました。プレミアムにアップグレードして制限を解除できます。';

  @override
  String get upgradeToExtendedAccess => '拡張アクセスへのアップグレード';

  @override
  String get loginRequired => 'ログインが必要です';

  @override
  String get loginRequiredDesc =>
      'AI アシスタントと支出受信箱を使用するには、ログインするかアカウントを作成する必要があります。';

  @override
  String get loginOrSignUp => 'ログイン/サインアップ';

  @override
  String get aiAnalyzingExpense => 'AI があなたの支出を分析しています...';

  @override
  String get draftAddedToInbox => '経費草案が受信箱に追加されました。';

  @override
  String get analysisError => 'トランザクションの分析中にエラーが発生しました。';

  @override
  String get scanningReceipt => 'レシートをスキャンして情報を抽出しています...';

  @override
  String get receiptUnreadable => '領収書が読めない';

  @override
  String get receiptUnreadableDesc => 'アップロードされた画像では領収書や請求書の詳細は検出されませんでした。';

  @override
  String get receiptAddedToInbox => '受信データが受信トレイに正常に追加されました。';

  @override
  String get receiptReadError => 'レシートを読み取れませんでした。詳細を手動で入力するか、より鮮明な写真を撮ってください。';

  @override
  String get imageUploadError => '画像のアップロード中にエラーが発生しました。';

  @override
  String get draftDeleted => '経費草案は削除されました。';

  @override
  String get transactionProcessedSuccess => 'トランザクションはボールトに正常に処理されました。';

  @override
  String get transactionApprovalError => 'トランザクションの承認中にエラーが発生しました。';

  @override
  String get smartScanTitle => 'スマートスキャン';

  @override
  String pendingApprovalCount(int count) {
    return '承認待ちのトランザクション ( $count )';
  }

  @override
  String get clearAll => 'すべてクリア';

  @override
  String get smartInputHint => '例えば昨日はスターバックス フィルターコーヒー 120TL';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get inboxEmpty => '受信箱が空です';

  @override
  String get otherCategory => '他の';

  @override
  String get add => '追加';

  @override
  String get todayUpper => '今日';

  @override
  String get tomorrowUpper => '明日';

  @override
  String daysWithName(int count, String dayName) {
    return '$count 日 - $dayName';
  }

  @override
  String weeksLater(int count) {
    return '$count 週間後';
  }

  @override
  String daysCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 日',
      one: '1日',
    );
    return '$_temp0';
  }

  @override
  String weeksCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 週間',
      one: '1週間',
    );
    return '$_temp0';
  }

  @override
  String monthsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count か月',
      one: '1ヶ月',
    );
    return '$_temp0';
  }

  @override
  String yearsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count年',
      one: '1年',
    );
    return '$_temp0';
  }

  @override
  String get sharedExpenseAnalyzed => '共有経費が分析され、受信箱に追加されました。';

  @override
  String get limitExceeded => '制限を超えました';

  @override
  String get selectIcon => 'アイコンを選択';

  @override
  String optionsCount(int count) {
    return '$count オプション';
  }

  @override
  String get invalidAmountError => '有効な金額を入力してください。';

  @override
  String get maxAmountMustBePositive => '最大金額は 0 より大きくなければなりません。';

  @override
  String get minMustBeLessThanMax => '最小金額は最大金額よりも小さい必要があります。';

  @override
  String get selectAtLeastOneVault => 'トランザクション用に少なくとも 1 つのボールトを選択してください...';

  @override
  String get exchangeRatesNotLoaded =>
      '為替レートが読み込まれていません。異なる通貨での取引を追加/更新するには、レートを更新する必要があります。';

  @override
  String vaultCurrencyRateNotLoaded(String currency) {
    return '選択したボールトの通貨 ( $currency ) の為替レートがロードされていません。料金を更新する必要があります。';
  }

  @override
  String transactionSaveError(String error) {
    return 'トランザクションの保存中にエラーが発生しました: $error';
  }

  @override
  String get notificationPermissionDenied => '通知の許可が与えられませんでした。設定から有効にしてください。';

  @override
  String get defaultUser => 'ユーザー';

  @override
  String get premiumBadge => 'プレミアム';

  @override
  String get email => '電子メール';

  @override
  String get password => 'パスワード';

  @override
  String errorOccurred(String error) {
    return 'エラーが発生しました: $error';
  }

  @override
  String aboutVersion(String version) {
    return '$version • ❤️ で作られています';
  }

  @override
  String comingSoonDesc(String feature) {
    return '$feature 機能は間もなく導入される予定です。';
  }

  @override
  String get noVaultTransactions => 'ボールトのトランザクションが見つかりませんでした';

  @override
  String get recurring => '繰り返し発生する';

  @override
  String get thisWeek => '今週';

  @override
  String get thisMonth => '今月';

  @override
  String get thisYear => '今年';

  @override
  String vaultLimitReachedDesc(int count) {
    return '無料プランでは最大 $count 個のコンテナーを作成できます。プレミアムに切り替えて制限を解除できます。';
  }

  @override
  String get inAppNotifications => 'アプリ内通知';

  @override
  String get exchangeRatesNotLoadedVault =>
      '為替レートが読み込まれていません。保管庫の通貨を変更できませんでした。';

  @override
  String get cannotDeleteVault => 'ボールトを削除できません';

  @override
  String get cannotDeleteVaultDesc =>
      '少なくとも 1 つのアクティブなボールトがアプリ内に残る必要があります。別のボールトを作成してから、このボールトを削除できます。';

  @override
  String get exchangeRatesNotLoadedNewVault =>
      '為替レートが読み込まれていません。別の通貨でボールトを作成するには、レートを更新する必要があります。';

  @override
  String get systemNotificationsDisabled =>
      'システム通知の許可がオフです。 携帯電話の設定から通知許可を有効にしてください。';

  @override
  String get noNotificationHistory => '通知履歴がありません';

  @override
  String get noNotificationHistoryDesc => '以前にトリガーされたトランザクション アラームの履歴はありません。';

  @override
  String paymentDate(String date) {
    return 'お支払い: $date';
  }

  @override
  String get loginRequiredForPurchase => '購入を完了するには、ログインするか無料アカウントを作成してください。';

  @override
  String get unlockFinancialPotential => '経済的な可能性を 100% 解放します。';

  @override
  String get aiAnalysis => 'AI分析';

  @override
  String get aiAnalysisDesc => '無制限かつ詳細な AI 分析。';

  @override
  String get unlimitedVaultsDesc => '必要な数のボールトとウォレットを作成します。';

  @override
  String get cloudSyncDesc => 'データを安全にバックアップして同期します。';

  @override
  String get customThemes => 'カスタムテーマ';

  @override
  String get customThemesDesc => '独自のカラーパレットと背景スタイル。';

  @override
  String get zeroAds => '広告ゼロ';

  @override
  String get zeroAdsDesc => '中断のない広告なしのプレミアム体験。';

  @override
  String get availablePlans => '利用可能なプラン';

  @override
  String get yearlyPremium => '年間保険料';

  @override
  String get monthlyPremium => '月額保険料';

  @override
  String get bestValueFreeTrialSubtitle => '最高の価値 • 7 日間の無料トライアル';

  @override
  String get cancelAnytime => 'いつでもキャンセル可能';

  @override
  String get bestValue => 'ベストバリュー';

  @override
  String get yearlyPremiumSimulated => '年間保険料（模擬）';

  @override
  String get monthlyPremiumSimulated => '月額保険料（模擬）';

  @override
  String get subscriptionAutoRenewalNote =>
      'サブスクリプションは自動的に更新されます。いつでもキャンセルできます。';

  @override
  String get sessionNotFound => 'ユーザーセッションが見つかりません。再度ログインしてください。';

  @override
  String get upgradeToPremiumTitle => 'Finarcast プレミアムにアップグレードする';

  @override
  String get yearlyPremiumSimulatedPrice => '\$39.99/年';

  @override
  String get yearlyPremiumSimulatedSubtitle => '月額 \$3.33 • 7 日間の無料トライアル';

  @override
  String get monthlyPremiumSimulatedPrice => '\$4.99/月';

  @override
  String get currencyTRY => 'トルコリラ';

  @override
  String get currencyUSD => '米ドル';

  @override
  String get currencyEUR => 'ユーロ';

  @override
  String get currencyGBP => '英国ポンド';

  @override
  String get currencyJPY => '日本円';

  @override
  String get currencyKRW => '韓国ウォン';

  @override
  String get currencyCNY => '中国人民元';

  @override
  String get currencyBRL => 'ブラジルレアル';

  @override
  String get currencyCHF => 'スイスフラン';

  @override
  String get currencyGOLD => '金（グラム）';

  @override
  String get currencyGOLDOunce => 'ゴールド (オンス)';

  @override
  String get currencySILVER => 'シルバー（グラム）';

  @override
  String get currencySILVEROunce => 'シルバー (オンス)';

  @override
  String get currencySAR => 'サウジアラビアリヤル';

  @override
  String get currencyKWD => 'クウェート ディナール';

  @override
  String get vaultGuideTitle => '保管庫ガイド';

  @override
  String get vaultGuideContent =>
      '📊 これらの数字は何を意味しますか? • 保管庫残高 (ウォレット): 保管庫のこれまでの累積正味残高。これは、初期のボールト残高と開始以降に記録されたすべての取引の合計です。 • 収入 (今月): 現在の暦月の合計推定収入。 • 経費 (今月): 現在の暦月の推定経費の合計。 💡 重要な注意事項: メイン残高は累計（常時）なので、当月の収支の純差額とは異なるのが普通です。';

  @override
  String get gotIt => 'わかった';

  @override
  String get startDate => '開始日';

  @override
  String get daily => '毎日';

  @override
  String get weekdays => '平日';

  @override
  String get weekends => '週末';

  @override
  String everyXDays(Object count) {
    return '$count日ごと';
  }

  @override
  String everyXWeeks(Object count) {
    return '$count 週間ごと';
  }

  @override
  String everyXMonths(Object count) {
    return '$count か月ごと';
  }

  @override
  String everyXYears(Object count) {
    return '$count年ごと';
  }

  @override
  String get incomePerMonthLabel => '収入 / 月';

  @override
  String get expensePerMonthLabel => '費用/月';

  @override
  String get transactionNoteHint => '取引のメモを残してください...';

  @override
  String get weekdaysShort => 'WKD';

  @override
  String get weekendsShort => 'ウェイク';

  @override
  String get reminderDay => 'リマインダーデー';

  @override
  String get reminderTime => 'リマインダー時間';

  @override
  String get reminder => 'リマインダー';

  @override
  String get sameDay => '同日';

  @override
  String get oneDayBefore => '1日前';

  @override
  String get twoDaysBefore => '2日前';

  @override
  String get threeDaysBefore => '3日前';

  @override
  String get oneWeekBefore => '1週間前';

  @override
  String get unknown => '未知';

  @override
  String get syncErrorDisabled => '同期は無効になっています。';

  @override
  String get syncErrorPremiumRequired => 'クラウド同期機能はプレミアム会員限定です。';

  @override
  String get syncSuccess => '同期が完了しました。';

  @override
  String syncSuccessWithErrors(num errorCount) {
    String _temp0 = intl.Intl.pluralLogic(
      errorCount,
      locale: localeName,
      other: '同期中に $errorCount エラーが発生しました。',
      one: '同期中に 1 件のエラーが発生しました。',
    );
    return '$_temp0';
  }

  @override
  String get syncErrorProjectPaused =>
      'クラウド データベース プロジェクトは一時停止されています。 Supabase ダッシュボードからプロジェクトを再アクティブ化してください。';

  @override
  String get syncErrorSessionExpired =>
      'セッションの有効期限が切れている可能性があります。 「設定」＞「ログアウト」からログアウトし、再度ログインしてください。';

  @override
  String get syncErrorNoInternet => 'インターネット接続を確立できませんでした。インターネット接続を確認してください。';

  @override
  String get syncErrorTablesMissing =>
      'データベーステーブルが見つかりません。 Supabase SQL エディタで setup.sql スクリプトを実行してください。';

  @override
  String get syncErrorPermissionDenied =>
      'データベース アクセス許可エラー (RLS)。 Supabase テーブルで RLS ポリシーが正しく構成されていることを確認してください。';

  @override
  String syncErrorUnexpected(Object error) {
    return '予期しないエラー: $error';
  }

  @override
  String syncErrorPostgrest(Object code, Object message) {
    return 'クラウド エラー ( $code ): $message';
  }

  @override
  String syncErrorAuth(Object code, Object message) {
    return '認証エラー ( $code ): $message';
  }

  @override
  String activeVaults(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'アクティブなボールト',
      one: 'アクティブなボールト',
    );
    return '$_temp0';
  }

  @override
  String get vaultsUpper => '保管庫';

  @override
  String get receiptExpense => '領収費';

  @override
  String get reasonSmartInput => 'クイックテキスト入力';

  @override
  String get reasonReceiptScan => '領収書の写真';

  @override
  String get reasonClipboard => 'クリップボード通知';

  @override
  String get noteCapturedFromClipboard => 'クリップボードからキャプチャ';

  @override
  String get notificationChannelName => '取引リマインダー';

  @override
  String get notificationChannelDesc => '定期的な支払いと収入のリマインダー';

  @override
  String get notificationTestChannelName => 'テスト通知';

  @override
  String get notificationTestChannelDesc => 'Finarcast 通知テスト チャネル';

  @override
  String get notificationTestTitle => 'Finarcast テストの通知';

  @override
  String get notificationTestBody => '素晴らしい！アプリ内 (フォアグラウンド) 通知はスムーズに機能しています。';

  @override
  String get notificationTestDelayedTitle => 'Finarcast 遅延テスト';

  @override
  String get notificationTestDelayedBody => 'アプリ外（バックグラウンド）通知テストが正常に完了しました。';

  @override
  String notificationIncomeTitle(Object title) {
    return '収入リマインダー: $title';
  }

  @override
  String notificationExpenseTitle(Object title) {
    return '支払いリマインダー: $title';
  }

  @override
  String notificationBodyAmount(Object amount) {
    return '金額: $amount';
  }

  @override
  String notificationBodyDate(Object date) {
    return '日付: $date';
  }

  @override
  String notificationBodyNote(Object note) {
    return '注: $note';
  }

  @override
  String get aiErrorRateLimit =>
      '1 日あたりの AI 分析の制限に達しました。プレミアムにアップグレードするか、明日もう一度お試しください。';

  @override
  String get aiErrorUnauthorized => '不正アクセス。再度ログインしてください。';

  @override
  String get aiErrorQuota => 'AIの使用制限に達しました。しばらく待ってから、もう一度試してください。';

  @override
  String get aiErrorBusy => 'AIサーバーがビジー状態です。数秒後にもう一度試してください。';

  @override
  String get aiErrorApiKey => 'AI API キーが無効か、見つかりません。設定を確認してください。';

  @override
  String get aiErrorTimeout => 'リクエストがタイムアウトしました。インターネット接続を確認して、もう一度試してください。';

  @override
  String aiErrorGeneric(Object error) {
    return 'AI 分析が失敗しました: $error';
  }

  @override
  String get vaultTransfer => '口座間移動';

  @override
  String daysShort(Object count) {
    return '$count日';
  }

  @override
  String get recurrenceDay => '繰り返し日';

  @override
  String dayOfMonthFormatted(Object day) {
    return '毎月$day日';
  }

  @override
  String get recurrenceDate => '繰り返し日';

  @override
  String occurrencesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回',
    );
    return '$_temp0';
  }

  @override
  String get plans => 'プラン';

  @override
  String installmentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回払い',
    );
    return '$_temp0';
  }

  @override
  String get installment => '分割払い';

  @override
  String get paymentOrder => '支払い順序';

  @override
  String paymentNumber(Object number) {
    return '第$number回目の支払い';
  }

  @override
  String percentFormat(Object value) {
    return '$value%';
  }

  @override
  String get selectValidTargetVault => '有効な移動先口座を選択してください。';

  @override
  String get sourceAndTargetVaultSame => '移動元口座と移動先口座は同じにできません。';

  @override
  String get targetVault => '移動先口座';

  @override
  String get editPlan => 'プランを編集';

  @override
  String get newPlan => '新規プラン';

  @override
  String get editTransaction => '取引を編集';

  @override
  String get navDashboard => 'ダッシュボード';

  @override
  String get navVaults => '金庫';

  @override
  String get navSmartScan => 'スキャン';

  @override
  String get navSettings => '設定';
}
