from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
import json

# Initialize Flask app and enable CORS for all origins
app = Flask(__name__)  # Corrected from _name_ to __name__
CORS(app)  # Allow all origins by default

# Route to verify the server is running
@app.route('/', methods=['GET'])
def index():
    return "Welcome to the Python Code Runner!"

# Route to execute Python code
@app.route('/run', methods=['POST'])
def run_code():
    try:
        # Ensure the request has JSON content
        if not request.is_json:
            return jsonify({'error': 'Content-Type must be application/json'}), 415

        # Parse the incoming JSON request
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Invalid JSON or no data provided!'}), 400

        code = data.get("code", "").strip()  # Extract code from request
        if not code:
            return jsonify({'error': 'No code provided!'}), 400  # Handle missing code

        # Execute the provided Python code
        result = subprocess.run(
            [r'C:\Users\91828\anaconda3\python.exe', '-c', code],  # Use the correct Python path
            capture_output=True,  # Capture both stdout and stderr
            text=True,  # Get output as text (not bytes)
            timeout=10  # Set a timeout for code execution (10 seconds)
        )

        # Prepare response with the code output or error
        output = result.stdout.strip()
        error = result.stderr.strip()
        return jsonify({'output': output, 'error': error}), 200

    except json.JSONDecodeError:
        return jsonify({'error': 'Request must be valid JSON!'}), 400

    except subprocess.TimeoutExpired:
        return jsonify({'error': 'Code execution timed out!'}), 408

    except Exception as e:
        print(f"Unexpected error: {str(e)}")  # Log error for debugging
        return jsonify({'error': f'An unexpected error occurred: {str(e)}'}), 500
if __name__ == '__main__':
    app.run(host='192.168.56.1', port=5005, debug=True)

