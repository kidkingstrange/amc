# tools/build_clues.py
import json
import re

def clean_answer(raw: str) -> str:
    # Keep only A-Z and 0-9, convert to uppercase
    cleaned = re.sub(r'[^A-Za-z0-9]', '', raw).upper()
    return cleaned

def truncate_clue(text: str, max_len=79) -> str:
    if len(text) <= max_len:
        return text
    return text[:max_len-3] + "..."

def main():
    with open('content/titles.json', 'r', encoding='utf-8') as f:
        titles = json.load(f)

    clues = []
    seen_ids = set()

    def add_clue(title_id, c_type, clue_text, raw_answer, diff, spoiler="none"):
        ans = clean_answer(raw_answer)
        if len(ans) < 3 or len(ans) > 15:
            return  # skip if out of bounds for crossword grid
        
        # Build unique id
        base_id = f"clue-{title_id.replace('anime-', 'a-').replace('movie-', 'm-')}-{c_type}"
        clue_id = base_id
        counter = 1
        while clue_id in seen_ids:
            counter += 1
            clue_id = f"{base_id}-{counter}"
        seen_ids.add(clue_id)

        clues.append({
            "id": clue_id,
            "titleId": title_id,
            "type": c_type,
            "clue": truncate_clue(clue_text),
            "answer": ans,
            "difficulty": diff,
            "spoiler": spoiler
        })

    for item in titles:
        t_id = item['id']
        t_title = item['title']
        t_year = str(item['year'])
        t_creator = item['studioOrDirector']
        t_type = item['type']
        chars = item.get('characters', [])
        terms = item.get('keyTerms', [])
        facts = item.get('facts', [])
        genres = item.get('genres', [])

        # 1. Title Clue (Easy / Medium)
        # Choose single memorable word if title is multiple words, or full title if <= 15 chars
        clean_title = clean_answer(t_title)
        if 3 <= len(clean_title) <= 15:
            add_clue(t_id, "title", f"{t_year} {genres[0].lower()} {t_type} directed by {t_creator}" if t_type == "movie" else f"{t_year} hit {t_type} by {t_creator}", clean_title, "easy")
        else:
            # Pick first or main word of title
            words = [w for w in re.split(r'[:\s\-]', t_title) if len(clean_answer(w)) >= 3]
            if words:
                word = words[0]
                add_clue(t_id, "title", f"First word in the title of the {t_year} {t_type}", word, "easy")

        # 2. Studio / Director Clue (Medium / Hard)
        creator_parts = re.split(r'[/,]', t_creator)
        for cp in creator_parts:
            # Extract last name for directors, or main name for studios
            tokens = cp.strip().split()
            if tokens:
                target_token = tokens[-1] if t_type == "movie" else tokens[0]
                if t_type == "movie":
                    add_clue(t_id, "creator", f"Director of {t_title} ({t_year})", target_token, "medium")
                else:
                    add_clue(t_id, "creator", f"Animation studio behind {t_title}", target_token, "hard")
                break

        # 3. Release Year Clue (Expert / Hard)
        add_clue(t_id, "year_number", f"Release year of {t_title}", t_year, "expert")

        # 4. Character Clues (2 to 4 characters per title)
        diff_ladder = ["easy", "medium", "hard", "expert"]
        for idx, char_name in enumerate(chars[:4]):
            char_tokens = re.split(r'[\s/]', char_name)
            # Pick the most recognizable single name
            chosen_token = char_tokens[0] if len(clean_answer(char_tokens[0])) >= 3 else (char_tokens[-1] if len(char_tokens) > 1 else char_name)
            char_diff = diff_ladder[min(idx, len(diff_ladder)-1)]
            role_desc = "Main character" if idx == 0 else "Prominent character"
            add_clue(t_id, "character", f"{role_desc} in {t_title}", chosen_token, char_diff)

        # 5. Key Terms / Abilities / Artifacts (2 to 3 per title)
        for idx, term in enumerate(terms[:3]):
            term_tokens = term.split()
            term_word = term_tokens[0] if len(clean_answer(term_tokens[0])) >= 3 else term
            term_diff = "medium" if idx == 0 else "hard"
            add_clue(t_id, "term", f"Iconic element or term in {t_title}", term_word, term_diff)

        # 6. Fill-in-the-blank or Fact Clue
        words = t_title.split()
        if len(words) > 1:
            missing = words[-1] if len(clean_answer(words[-1])) >= 3 else words[0]
            masked_title = t_title.replace(missing, "___")
            add_clue(t_id, "fill_in_blank", f"Fill in the blank: '{masked_title}'", missing, "easy")
        elif facts:
            fact_words = [w for w in re.split(r'[\s,.]', facts[0]['text']) if 4 <= len(clean_answer(w)) <= 10]
            if fact_words:
                add_clue(t_id, "term", f"Key keyword from trivia of {t_title}", fact_words[0], "hard")

    print(f"Total clues generated: {len(clues)}")
    with open('content/clues.json', 'w', encoding='utf-8') as f:
        json.dump(clues, f, indent=2, ensure_ascii=False)
    print("Saved to content/clues.json.")

if __name__ == '__main__':
    main()
