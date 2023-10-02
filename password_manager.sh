#!/usr/bin/bash

plaintext_file="login_info.txt"
encrypt_file="login_info.gpg"

echo "パスワードマネージャーへようこそ！"

while :
do
	read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" selected_command
	echo

	if [ "$selected_command" = "Add Password" ]; then

		passphrase="passphrase"
		
		# 暗号化されたファイルがすでにあれば復号化
		if [ -e "$encrypt_file" ]; then
			read -s -p "登録したパスフレーズを入力してください：" passphrase
			echo
			echo
			echo "$passphrase" | gpg --batch --passphrase-fd 0 -d --yes --output "$plaintext_file" "$encrypt_file" 2>/dev/null

			# パスフレーズが間違っていた場合は後の処理に進まない
			if [ $? -ne 0 ]; then
				echo "パスフレーズが間違っています。"
				echo
				# rm "$plaintext_file"
				continue
			fi

		# 初めてファイルを作成するとき
		else
			echo "パスフレーズを登録してください。"
			read -s -p "今後情報を登録したり閲覧するときは、ここで登録したパスフレーズを入力してください：" passphrase
			echo
			echo
		fi
		
		# 情報を入力してもらう
		read -p "サービス名を入力してください：" service_name
		read -p "ユーザー名を入力してください：" user_name
		read -s -p "パスワードを入力してください：" password
		echo
		echo
		
		# 復号化したファイルに情報を追記
		echo "${service_name}:${user_name}:${password}" >> "$plaintext_file"
		
		# 情報を追記したら暗号化
		echo "$passphrase" | gpg --batch --passphrase-fd 0 -c --yes --output "$encrypt_file" "$plaintext_file"

		# 暗号化する前のファイルを削除
		rm "$plaintext_file"

		echo "パスワードの追加は成功しました。"
		echo

	elif [ "$selected_command" = "Get Password" ]; then

		# ファイルを復号化
		read -s -p "登録したパスフレーズを入力してください：" passphrase
		echo
		echo
		echo "$passphrase" | gpg --batch --passphrase-fd 0 -d --yes --output "$plaintext_file" "$encrypt_file" 2>/dev/null

		# パスフレーズが間違っていた場合は後の処理に進まない
		if [ $? -ne 0 ]; then
			echo "パスフレーズが間違っています。"
			echo
			# rm "$plaintext_file"
			continue
		fi
		
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
