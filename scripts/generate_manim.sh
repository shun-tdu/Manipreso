# --- 設定 ---
# コンテナ内のパスを指定
MD_FILE="/data/presentation.md"          # 入力 (ホストPCからマウント)
PROMPT_TEMPLATE="/app/master_prompt.txt" # 入力 (コンテナ内)
OUTPUT_PY_FILE="/data/presentation.py"   # 出力 (ホストPCへ)
OUTPUT_VIDEO_DIR="/data/media"           # 出力 (ホストPCへ)

# --- 1. APIキーのチェック ---
if [ -z "$GEMINI_API_KEY" ]; then
  echo "エラー: 環境変数 GEMINI_API_KEY が設定されていません。"
  echo ".envファイルにGEMINI_API_KEYを設定してください。"
  exit 1
fi
echo "APIキーを認識しました。"

# --- 2. 入力ファイルのチェック ---
if [ ! -f "$MD_FILE" ]; then
  echo "エラー: 入力ファイル $MD_FILE が見つかりません。"
  echo "プロジェクトのルートに presentation.md が存在するか確認してください。"
  exit 1
fi

# --- 3. プロンプトの構築 ---
echo "プロンプトを構築中..."
MD_CONTENT=$(cat "$MD_FILE")
PROMPT_TEMPLATE_CONTENT=$(cat "$PROMPT_TEMPLATE")
FINAL_PROMPT="${PROMPT_TEMPLATE_CONTENT/\{\{MARKDOWN_CONTENT\}\}/$MD_CONTENT}"

# --- 4. LLMによるManimコード生成 ---
echo "Gemini (Python) を呼び出し、Manimコードを生成中..."

# echo でプロンプトを渡し、パイプ (|) で call_gemini.py に渡す
# 実行結果 (標準出力) が GENERATED_CODE に格納される
GENERATED_CODE=$(echo "$FINAL_PROMPT" | python /app/call_gemini.py)

# エラーチェック (Pythonスクリプトが失敗したらshも終了する)
if [ $? -ne 0 ]; then
    echo "エラー: Manimコードの生成に失敗しました。"
    exit 1
fi

# 生成されたコード（Pythonのprint結果）をファイルに保存
echo "$GENERATED_CODE" > "$OUTPUT_PY_FILE"

echo "--- 生成されたコード ---"
cat "$OUTPUT_PY_FILE"
echo "---------------------------"


# --- 5. Manimによる動画レンダリング ---
echo "Manimを実行して動画をレンダリング中..."
# -q (品質) -l (低品質) や -p (プレビュー) は適宜調整
# --output_dir で、マウントされた /data/media に出力する
manim -qm -m "$OUTPUT_PY_FILE" --output_dir "$OUTPUT_VIDEO_DIR"

echo "完了！ $OUTPUT_VIDEO_DIR に動画ファイルが生成されました。"