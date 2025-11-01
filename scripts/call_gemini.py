import os
import sys
import google.generativeai as genai

# APIキーを環境変数から読み込む
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    print("エラー: 環境変数 GEMINI_API_KEY が設定されていません。", file=sys.stderr)
    sys.exit(1)

genai.configure(api_key=api_key)
model = genai.GenerativeModel('gemini-pro')

# 2. シェルスクリプトからのプロンプトを「標準入力」から受け取る
prompt = sys.stdin.read()

try:
    # 3. APIを呼び出す
    response = model.generate_content(prompt)

    # 4. 結果のテキストだけを「標準出力」に書き出す
    # (```python ... ``` のようなマークダウンを除去する処理)
    if response.parts:
        code = response.text
        if code.startswith("```python"):
            code = code.strip("```python\n")
        if code.endswith("```"):
            code = code.strip("\n```")
        print(code)
    else:
        print(f"エラー: Geminiから有効なレスポンスがありませんでした。\n{response.prompt_feedback}", file=sys.stderr)
        sys.exit(1)

except Exception as e:
    print(f"Gemini API呼び出し中にエラー: {e}", file=sys.stderr)
    sys.exit(1)