import os
import re
import sys

# Ignore l10n directory
IGNORE_DIRS = ['lib/l10n']
# Ignore g.dart files
IGNORE_EXTENSIONS = ['.g.dart']

# Ignored technical words/patterns
TECHNICAL_PATTERNS = [
    r'^[a-zA-Z0-9_\-]+/[a-zA-Z0-9_\-\.]+$', # Asset paths, mime types
    r'^[A-Z0-9_]+$', # Constant identifiers or currency codes (e.g., USD, TRY)
    r'^[a-z]+_[a-z]+$', # DB table/column names (e.g., user_id, updated_at)
    r'^[a-z]+[A-Z][a-zA-Z0-9]*$', # camelCase technical strings
    r'^\d+(\.\d+)?$', # Numbers
    r'^#?[0-9a-fA-F]{6}$', # Hex color codes
    r'^MaterialIcons$',
    r'^https?://',
    r'^\s*$', # Whitespace only
]

# Common words to ignore (technical symbols, route names, provider names)
IGNORED_EXACT_STRINGS = {
    'tr', 'en', 'de', 'es', 'fr', 'it', 'ja', 'ko', 'pt', 'zh',
    'TRY', 'USD', 'EUR', 'GBP', 'JPY', 'KRW', 'CNY', 'BRL', 'CHF', 'GOLD', 'SILVER', 'SAR', 'KWD', 'AUTO',
    '₺', '$', '€', '£', '¥', '₩', '元', 'R$', 'Fr', 'g', 'oz', 'oz.', 'SR', 'KD', '—', '≈', '...', '•',
    '/', 'auth', 'home', 'settings', 'vaults', 'transactions', 'inbox', 'pro', 'profiles', 'decisions',
    'id', 'name', 'currency', 'balance', 'date', 'note', 'amount', 'color', 'icon', 'rate',
    'updated_at', 'created_at', 'user_id', 'db', 'guest', 'email', 'password', 'username',
    'gun', 'hafta', 'ay', 'yil', 'tr_TR', 'en_US', 'yyyy-MM-dd', 'yMMMd', 'MMMMd', 'd MMMM', 'd', 'M', 'y', 'H:m', 'HH:mm',
    'Finarcast_is_guest_mode', 'Finarcast', 'Segoe UI', 'Roboto', 'Inter', 'Outfit', 'MaterialIcons',
    'application/json', 'image/jpeg', 'image/png', 'image/webp',
    'email_address', 'current_password', 'new_password', 'confirm_new_password',
}

def is_technical(s):
    s_stripped = s.strip()
    if not s_stripped:
        return True
    if len(s_stripped) <= 2:
        # Most very short strings are symbols, unit labels, or codes
        return True
    if s_stripped in IGNORED_EXACT_STRINGS:
        return True
    for pattern in TECHNICAL_PATTERNS:
        if re.match(pattern, s_stripped):
            return True
    return False

def clean_code(content):
    # Remove multi-line comments
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    # Remove single-line comments
    content = re.sub(r'//.*?\n', '\n', content)
    return content

def extract_strings(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    cleaned = clean_code(content)
    lines = cleaned.split('\n')
    results = []
    
    # Regex to find single quoted or double quoted strings
    # Captures: '...', "...", '''...''', """..."""
    # Handles escaped quotes
    string_regex = re.compile(r'r?\'\'\'(.*?)\'\'\'|r?"""(.*?)"""|r?\'([^\'\\]*(?:\\.[^\'\\]*)*)\'|r?"([^"\\]*(?:\\.[^"\\]*)*)"', re.DOTALL)
    
    for idx, line in enumerate(lines, 1):
        # Ignore debug statements, imports, logs, database schema code, exceptions
        line_lower = line.lower()
        if any(w in line_lower for w in ['import ', 'part ', 'export ', 'debugprint', 'print(', 'log(', 'logger.', 'throw ', 'exception(', 'assert(', 'r\'properties\'', 'r\'languagecode\'']):
            continue
            
        matches = string_regex.findall(line)
        for match in matches:
            # Match is a tuple since we have 4 capture groups
            val = next((group for group in match if group), None)
            if val:
                # Check if it has alphabetic characters (Turkish or English)
                if re.search(r'[a-zA-ZğüşöçİĞÜŞÖÇ]', val):
                    if not is_technical(val):
                        results.append((idx, val, line.strip()))
                        
    return results

def safe_print(s):
    try:
        print(s)
    except UnicodeEncodeError:
        # Encode as utf-8 and back or replace characters that console cannot display
        print(s.encode(sys.stdout.encoding, errors='replace').decode(sys.stdout.encoding))

def main():
    root_dir = 'c:\\Users\\Yasir2.Prenses\\Finarcast\\lib'
    found_any = False
    
    safe_print("Scanning Dart files for potential hardcoded strings...")
    safe_print("-" * 80)
    
    for root, dirs, files in os.walk(root_dir):
        # Skip ignored directories
        rel_root = os.path.relpath(root, root_dir)
        if any(root.replace('\\', '/').endswith(d) or f'/{d}/' in root.replace('\\', '/') for d in IGNORE_DIRS):
            continue
            
        for file in files:
            if not file.endswith('.dart'):
                continue
            if any(file.endswith(ext) for ext in IGNORE_EXTENSIONS):
                continue
                
            file_path = os.path.join(root, file)
            rel_path = os.path.relpath(file_path, root_dir)
            
            try:
                matches = extract_strings(file_path)
                if matches:
                    found_any = True
                    safe_print(f"\nFile: lib\\{rel_path}")
                    for line_num, val, line_content in matches:
                        safe_print(f"  Line {line_num:4d}: \"{val}\"")
                        safe_print(f"    Code: {line_content}")
            except Exception as e:
                safe_print(f"Error reading {file_path}: {e}")
                
    if not found_any:
        safe_print("\nSUCCESS: No hardcoded user-visible strings found in any Dart files!")
    safe_print("-" * 80)

if __name__ == '__main__':
    main()
