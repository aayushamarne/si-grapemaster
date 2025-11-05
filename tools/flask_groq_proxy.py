from flask import Flask, request, Response, jsonify
import os
import requests

app = Flask(__name__)

# Default values; for convenience we default to the user's provided key if no env var is set.
DEFAULT_GROQ_KEY = os.getenv('GROQ_API_KEY', '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')
# Groq uses the OpenAI-compatible API format
DEFAULT_GROQ_ENDPOINT = os.getenv('GROQ_ENDPOINT', 'https://api.groq.com/openai/v1/chat/completions')
DEFAULT_MODEL = os.getenv('GROQ_MODEL', 'llama-3.1-8b-instant')

# Read from env or fallback to defaults
GROQ_API_KEY = os.getenv('GROQ_API_KEY', DEFAULT_GROQ_KEY)
GROQ_ENDPOINT = os.getenv('GROQ_ENDPOINT', DEFAULT_GROQ_ENDPOINT)
GROQ_MODEL = os.getenv('GROQ_MODEL', DEFAULT_MODEL)

# Simple health check
@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'})

# Single endpoint that accepts chat-style messages and forwards to Groq provider.
@app.route('/generate', methods=['POST'])
def generate():
    try:
        payload = request.get_json(force=True)
    except Exception as e:
        print(f"JSON parse error: {e}")
        return jsonify({'error': 'Invalid JSON'}), 400

    print(f"Received payload: {payload}")

    # Convert simple {"input": "text"} format to Groq's chat completion format
    # Groq expects: {"model": "...", "messages": [{"role": "user", "content": "..."}]}
    if 'input' in payload:
        # Simple format from app
        user_message = payload['input']
        forward_body = {
            'model': GROQ_MODEL,
            'messages': [
                {'role': 'user', 'content': user_message}
            ]
        }
    else:
        # Already in chat format
        forward_body = payload
        if 'model' not in forward_body:
            forward_body['model'] = GROQ_MODEL

    print(f"Forwarding to Groq: {forward_body}")

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {GROQ_API_KEY}',
    }

    try:
        resp = requests.post(GROQ_ENDPOINT, json=forward_body, headers=headers, timeout=30)
        print(f"Groq response status: {resp.status_code}")
        print(f"Groq response body: {resp.text[:500]}")
    except requests.exceptions.RequestException as e:
        print(f"Request error: {e}")
        return jsonify({'error': str(e)}), 502

    # Mirror status and body back to the client
    return Response(resp.content, status=resp.status_code, content_type=resp.headers.get('Content-Type', 'application/json'))

if __name__ == '__main__':
    # Listen on all interfaces so physical devices can reach the host by IP
    port = int(os.getenv('PROXY_PORT', '5000'))
    app.run(host='0.0.0.0', port=port)
