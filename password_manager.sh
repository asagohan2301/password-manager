#!/usr/bin/bash

plaintext_file="login_info.txt"
encrypt_file="login_info.gpg"

echo "パスワードマネージャーへようこそ！"

while :
do
	read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" selected_command
	echo

	if [ "$selected_command" = "Add Password" ]; then

		read -p "サービス名を入力してください：" service_name
		read -p "ユーザー名を入力してください：" user_name
		read -s -p "パスワードを入力してください：" password
		echo
		echo
		
		# ファイルを復号化
		if [ -e "$encrypt_file" ]; then
			read -s -p "前回暗号化したときと同じパスフレーズを入力してください: " passphrase_p
			echo
			echo "$passphrase_p" | gpg --batch --passphrase-fd 0 -d --yes --output "$plaintext_file" "$encrypt_file"
		fi
		
		# 復号化したファイルに情報を追記
		echo "${service_name}:${user_name}:${password}" >> "$plaintext_file"
		
		# 情報を追記したら暗号化
		read -s -p "暗号化するためのパスフレーズを入力してください: " passphrase_e
		echo
		echo "$passphrase_e" | gpg --batch --passphrase-fd 0 -c --yes --output "$encrypt_file" "$plaintext_file"

		# 暗号化する前のファイルを削除
		rm "$plaintext_file"

		echo
		echo "パスワードの追加は成功しました。"
		echo

	elif [ "$selected_command" = "Get Password" ]; then

		# ファイルを復号化
		read -s -p "前回暗号化したときと同じパスフレーズを入力してください: " passphrase
		echo
		echo "$passphrase" | gpg --batch --passphrase-fd 0 -d --yes --output "$plaintext_file" "$encrypt_file"
		
		# 復号化したファイルから情報を検索
		read -p "サービス名を入力してください：" input_service_name
		echo
		IFS=":"
		read -r service_name user_name password <<< "$(grep "^$input_service_name" "$plaintext_file")"
		
		# 情報を取得したら、同じパスフレーズでファイルを暗号化
		echo "$passphrase" | gpg --batch --passphrase-fd 0 -c --yes --output "$encrypt_file" "$plaintext_file"

		# 暗号化する前のファイルを削除
		rm "$plaintext_file"
		
		# 情報を表示
		if [ "$input_service_name" != "$service_name" ]; then
			echo "そのサービスは登録されていません。"
			echo
		else
			echo "サービス名：${service_name}"
			echo "ユーザー名：${user_name}"
			echo "パスワード：${password}"
			echo
		fi

	elif [ "$selected_command" = "Exit" ]; then

		echo "Thank you!"
		break

	else

		echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
		echo

	fi
done
