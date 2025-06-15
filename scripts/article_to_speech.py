import glob
import os

import openai

ARTICLES_DIR = os.path.join(os.path.dirname(__file__), '..', 'articles')
VLOG_DIR = os.path.join(os.path.dirname(__file__), '..', 'vlog')


def get_latest_article():
    files = glob.glob(os.path.join(ARTICLES_DIR, '*.txt'))
    return max(files, key=os.path.getctime) if files else None


def main():
    api_key = os.getenv('OPENAI_API_KEY')
    if not api_key:
        raise EnvironmentError('OPENAI_API_KEY environment variable not set')
    openai.api_key = api_key

    article = get_latest_article()
    if not article:
        print('No article files found.')
        return

    with open(article, 'r', encoding='utf-8') as f:
        text = f.read()

    response = openai.audio.speech.create(
        model='tts-1',
        voice='nova',
        input=text
    )

    base = os.path.splitext(os.path.basename(article))[0]
    os.makedirs(VLOG_DIR, exist_ok=True)
    out_path = os.path.join(VLOG_DIR, f'{base}.mp3')
    if os.path.exists(out_path):
        print(f"Audio for {article} already exists at {out_path}")
        return
    with open(out_path, 'wb') as f:
        f.write(response.content)
    print(f'Audio saved to {out_path}')


if __name__ == '__main__':
    main()
