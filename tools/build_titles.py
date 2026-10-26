# tools/build_titles.py
import json
import os
import tools.anime_data as anime
import tools.movies_data as movies

def main():
    all_titles = anime.ANIME_TITLES + movies.MOVIE_TITLES
    os.makedirs('content', exist_ok=True)
    out_path = os.path.join('content', 'titles.json')
    
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(all_titles, f, indent=2, ensure_ascii=False)
        
    print(f"Successfully generated {out_path} with {len(all_titles)} verified entries.")
    print(f"  - Anime: {len(anime.ANIME_TITLES)}")
    print(f"  - Movies: {len(movies.MOVIE_TITLES)}")

if __name__ == '__main__':
    main()
