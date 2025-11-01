FROM manimcommunity/manim:stable

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./scripts/ /app/

# スクリプトに実行権限を付与
RUN chmod +x /app/generate_manim.sh

# APIキー用の環境変数を宣言
ENV GEMINI_API_KEY=""

# 起動時の実行コマンドを設定
ENTRYPOINT [ "/app/generate_manim.sh" ]