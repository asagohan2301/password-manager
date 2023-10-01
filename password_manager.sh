#!/usr/bin/bash

echo "パスワードマネージャーへようこそ！"

while :
do
	read -p "次の選択肢から入力してください(Add Password/Get Password/Exit)：" SELECTED_COMMAND
	echo

	if [ "$SELECTED_COMMAND" = "Add Password" ]; then

		read -p "サービス名を入力してください：" SERVICE_NAME
		read -p "ユーザー名を入力してください：" USER_NAME
		read -p "パスワードを入力してください：" PASSWORD

		echo "${SERVICE_NAME}:${USER_NAME}:${PASSWORD}" >> login_info.txt

		echo
		echo "パスワードの追加は成功しました。"
		echo

	elif [ "$SELECTED_COMMAND" = "Get Password" ]; then

		read -p "サービス名を入力してください：" INPUT_SERVICE_NAME
		IFS=":"
		read -r SERVICE_NAME USER_NAME PASSWORD <<< "$(grep "^$INPUT_SERVICE_NAME" login_info.txt)"

		if [ "$INPUT_SERVICE_NAME" != "$SERVICE_NAME" ]; then
			echo "そのサービスは登録されていません。"
			echo
		else
			echo "サービス名：${SERVICE_NAME}"
			echo "ユーザー名：${USER_NAME}"
			echo "パスワード：${PASSWORD}"
			echo
		fi

	elif [ "$SELECTED_COMMAND" = "Exit" ]; then

		echo "Thank you!"
		break

	else

		echo "入力が間違えています。Add Password/Get Password/Exit から入力してください。"
		echo

	fi
done
