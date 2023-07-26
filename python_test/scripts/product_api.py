import json

from fastapi import FastAPI

def load_json_payloads():
    with open("resources/api_payloads.json", "r") as file:
        payloads = json.load(file)

    return payloads

app = FastAPI()

data = load_json_payloads()

@app.get("/myendpoint")
def get_myendpoint_data(page: int = None):

    if not page or page == 0:
        return data[0]

    if page > 0:
        page = page - 1
    return data[page]
