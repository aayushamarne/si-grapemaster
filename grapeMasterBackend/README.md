# Running the Disease Detection Backend

## Quick Start

1. **Navigate to the backend folder:**
   ```bash
   cd grapeMasterBackend
   ```

2. **Install dependencies:**
   ```bash
   pip install flask ultralytics torch
   ```

3. **Make sure `best.pt` model file exists in the folder**

4. **Run the server:**
   ```bash
   python app.py
   ```

   The server will start on `http://0.0.0.0:10000`

## Testing the API

Once the server is running, test it with:

```bash
cd ../tools
python simple_test.py path/to/grape_leaf_image.jpg
```

## API Response Format

The API returns JSON with this structure:

```json
{
  "prediction": "Disease Name",
  "confidence": 0.9543
}
```

## Troubleshooting

- **Model not found**: Make sure `best.pt` is in the `grapeMasterBackend` folder
- **Port already in use**: Check if another app is using port 10000
- **Import errors**: Install required packages with `pip install flask ultralytics torch`
