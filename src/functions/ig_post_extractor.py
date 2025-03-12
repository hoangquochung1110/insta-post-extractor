import json
import re
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from logging import INFO, getLogger
from typing import Any, Dict, List, Optional, Tuple, Union

import boto3

brt = boto3.client(service_name='bedrock-runtime', region_name='us-east-1')
model_id = "us.deepseek.r1-v1:0"

logger = getLogger(__name__)
logger.setLevel(INFO)


class OGTitleParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.title = None
    def handle_starttag(self, tag, attrs):
        if tag == 'meta' and dict(attrs).get('property') == 'og:title':
            self.title = dict(attrs).get('content')


def preprocess_html(raw_html: str) -> str:
    return re.sub(
        r'(\s*=\s*["\'])([\s\S]*?)(["\'])',
        lambda m: m.group(1) + m.group(2).replace('\n', ' ') + m.group(3),
        raw_html,
    )


def extract_og_title(raw_html: str) -> Optional[str]:
    parser = OGTitleParser()
    parser.feed(raw_html)
    return parser.title


def extract_address(text: str):
    response = brt.converse(
        modelId=model_id,
        messages=[{
            "role": "user",
            "content": [{"text": f"Extract address-like text from this following text if possible: {text}. Delimit it by triple backticks if found. Otherwise, return this string <None>"}]
        }],
        inferenceConfig={
            "maxTokens": 500,
            "temperature": 0.7,
            "topP": 0.9
        }
    )
    response_pattern = r"```(.*?)```"
    # Extract the response
    response_message = response.get('output', {}).get('message', {})
    generated_text = response_message.get('content', [{}])[0].get('text', '')
    print(generated_text)
    matches = re.findall(response_pattern, generated_text, re.DOTALL)

    google_maps_links = [
        "https://maps.google.com/?q=" + urllib.parse.quote_plus(address)
        for address in matches
    ]
    return google_maps_links if matches else []


def find_links(text: str) -> List[str]:
    pattern = r'(?<!@)(?:https?://)?(?:[a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+(?:/[^\s,]*)?[^\s,.]'
    links = re.findall(pattern, text, re.VERBOSE)
    return [
        'https://' + link
        if not link.startswith(('http://', 'https://')) else
        link
        for link in links
    ]


def extract_links_from_post(url: str) -> Tuple[List[str], str]:
    try:
        with urllib.request.urlopen(url) as response:
            html_content = response.read().decode('utf-8')
            og_title = extract_og_title(preprocess_html(html_content))
            if not og_title:
                return [], 'og:title not found'
            return find_links(og_title) if og_title else [], ''
    except Exception as e:  # pylint: disable=broad-except
        return [], str(e)

def extract_address_from_post(url: str) -> Tuple[List[str], str]:
    try:
        with urllib.request.urlopen(url) as response:
            html_content = response.read().decode('utf-8')
            og_title = extract_og_title(preprocess_html(html_content))
            if not og_title:
                return [], 'og:title not found'
            return extract_address(og_title) if og_title else [], ''
    except Exception as e:  # pylint: disable=broad-except
        return [], str(e)


def create_response(
    status_code: int,
    body: Optional[Union[Dict[str, Any], str]] = None,
    error: Optional[str] = None
) -> Dict[str, Any]:
    response_body = {
        'error': error
    } if error else (body if body else {})

    logger.info(f'Status: {status_code}, Response: {response_body}')

    return {
        'statusCode': status_code,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps(response_body, ensure_ascii=False),
    }


def lambda_handler(event, _context):
    try:
        url = json.loads(event['body']).get('url')

        logger.info(f'Request URL: {url}')

        if not url:
            return create_response(400, error='URL is required')

        if not (
            url.startswith('https://www.instagram.com/') or
            url.startswith('https://instagram.com/')
        ):
            return create_response(400, error='Invalid Instagram post URL')

        links, error_message = extract_address_from_post(url)
        logger.info(f'Links: {links}')
        logger.info(f'Error: {error_message}')
        if error_message:
            return create_response(400, error=error_message)
        elif len(links) == 0:
            return create_response(400, error='No address found in the post')

        return create_response(200, body={'links': links})

    except json.JSONDecodeError:
        logger.warning(f'Invalid JSON payload - {event["body"]}')
        return create_response(400, error='Invalid JSON payload')
    except Exception as e:  # pylint: disable=broad-except
        logger.exception(f'Error: {e}')
        return create_response(500, error=str(e))
