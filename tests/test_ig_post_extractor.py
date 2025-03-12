import json

from src.functions.ig_post_extractor import lambda_handler

valid_link = "https://www.instagram.com/p/DGxtXgrNFqy/"
invalid_link = "https://www.instagram.com/p/DHDFgs_T9J-/?utm_source=ig_web_copy_link"
body = json.dumps({"url": invalid_link})

event = {
    'body': body
}
res = lambda_handler(event, None)
print(res)
