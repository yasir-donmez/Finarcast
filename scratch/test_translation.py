from deep_translator import GoogleTranslator

try:
    translated = GoogleTranslator(source='en', target='de').translate('Save')
    print("Google success:", translated)
except Exception as e:
    print("Google failed:", e)
