# Store Listing + SEO Prompt — 5 Language Apps

Copy everything **below the line** and paste it into ChatGPT, Gemini, Claude, or any other AI.

---

You are a senior **ASO + SEO** specialist for Google Play and Apple App Store.

Create SEO-optimized store listings and identifiers for **5 separate baby flashcard apps**. Each language is its own app, its own listing, and its own keyword set. Do not treat this as one multilingual app.

SEO here means **App Store Optimization (ASO)**: rank for parent search queries in each country/language, with keyword-rich titles, short descriptions, full descriptions, and App Store keyword fields.

## Product facts

- Brand / current English name: **Baby Flash French**
- Audience: babies, toddlers, preschool kids (ages 1–6) and their parents
- What the app does: colorful flashcards with images + spoken audio to teach first words
- Categories inside the app:
  - Alphabet
  - Animals
  - Numbers
  - Body parts
  - Art & Music
  - Colors
  - Shapes
  - Fruits & Food
  - Vehicles & Transport
  - Sports & Outdoor items
  - Clothing
  - Home items
- Features: tap to hear pronunciation, swipe cards, optional question/quiz mode, background music on/off, large kid-friendly UI, works on phone and tablet
- Tone: warm, playful, simple, parent-trustworthy. No medical claims. No “guaranteed to make baby genius” claims.
- Monetization: ads (banner + interstitial). Do not mention ads in the store text unless needed for policy. Do not promise “100% ad-free”.
- Japanese version should **not** highlight Alphabet as a main feature.

## 5 apps to generate

1. English — target: US, UK, India, Australia, Canada
2. French — target: France, Belgium, Canada (French), Switzerland
3. Italian — target: Italy, Switzerland (Italian)
4. Japanese — target: Japan
5. Spanish — target: Spain, Mexico, Argentina, Colombia, US Spanish

## Package / bundle ID rules

Current IDs (English app today):
- Android: `com.baby_flash_apps`
- iOS: `com.babyFlashApps`

For the other 4 apps, suggest **unique** IDs:
- Android applicationId: lowercase, reverse-domain, letters/digits/underscore only. Example: `com.babyflash.spanish`
- iOS bundle ID: can use camelCase. Example: `com.babyFlashApps.spanish`
- Keep a shared brand prefix. No hyphens.
- English can keep current IDs, or suggest cleaner unique ones. Mark “keep current” if you keep them.

## Character limits (must not exceed)

**Google Play**
- App name / title: max **30** characters
- Short description: max **80** characters
- Full description: **1800–2800** characters (hard max 4000)

**Apple App Store**
- App name: max **30** characters
- Subtitle: max **30** characters
- Promotional text: max **170** characters
- Description: **1800–2800** characters (hard max 4000)
- Keywords: max **100** characters, comma-separated, **no spaces after commas**, no competitor brand names, no words already used in name/subtitle (those already index)

After every field, print the **character count**.

## Language of the copy

- Write all store copy **in that app’s language**.
- Also give an **English translation** of title + short description + primary keyword.
- Japanese: natural Japanese, not romaji in listing body.
- App names should be searchable by parents. A small English brand word like “Baby Flash” is OK if it fits 30 characters and still ranks.

## SEO / ASO rules (must follow)

### Keyword research first
Before writing copy for each language, pick keywords parents actually search:

**English examples:** baby flashcards, toddler flash cards, first words, ABC for kids, baby learning app, preschool flashcards, animals for toddlers, numbers for kids, baby vocabulary

**French examples:** cartes flash bébé, premières paroles, abécédaire, apprentissage bébé, vocabulaire enfant, cartes éducatives

**Italian examples:** flashcard bambini, prime parole, alfabeto bambini, apprendimento neonati, vocabolario bambini

**Japanese examples:** 赤ちゃん フラッシュカード, 幼児 英語, ことば カード, 知育 アプリ, 絵カード, 赤ちゃん 学習

**Spanish examples:** tarjetas didácticas bebé, primeras palabras, abecedario niños, aprendizaje bebé, vocabulario infantil, flashcards bebés

Do not copy these blindly. Localize, pick high-intent parent terms, and mix head terms + long-tail.

For **each app**, output:
- 1 primary keyword (highest ranking target)
- 5–8 secondary keywords
- 8–12 long-tail search queries (how a parent would type in the store)

### Title SEO
- Put the **primary keyword** as close to the start as possible.
- Formula: `Primary Keyword + Brand/Benefit`
- Example style: `Baby Flashcards - First Words` not `Baby Flash French Official`
- Unique per language. Do not use the same English title for all 5.
- No stuffing. Must still read like a real app name.

### Short description SEO (Play 80 chars)
- Must include primary keyword + 1 secondary keyword + 1 benefit.
- This field is heavily ranked on Google Play. Do not waste it on slogans with no keywords.

### Full description SEO
- First **3 lines** = hook + primary keyword + main benefit (visible before Read more).
- Use primary keyword in:
  - first sentence
  - one H2-style line or short paragraph heading
  - last paragraph / CTA
- Use secondary keywords naturally in body (animals, numbers, colors, first words, etc.).
- Keyword density: primary keyword about **2–4 times**. Never spam.
- Include a scannable feature list with keyword-rich bullets.
- Include a “Who is it for?” line (babies, toddlers, preschool, parents).
- Include a localized CTA at the end.
- Write for humans first, ranking second. No walls of keywords.

### App Store extra SEO
- Name: primary keyword
- Subtitle: 1–2 different high-volume keywords not already in the name
- Keywords field: remaining unique terms, misspellings only if common, synonyms, age terms (baby,toddler,preschool), category terms (animals,abc,numbers)
- Do **not** repeat words already in name or subtitle in the keyword field
- Do **not** use: free, app, the, and, or competitor names (YouTube Kids, Khan Academy Kids, Lingokids, etc.)

### SEO do / don’t
- DO target parent intent: teach baby words, toddler learning, flashcards with sound
- DO use localized words for baby/toddler/preschool in each language
- DO keep claims honest
- DON’T keyword stuff
- DON’T use “#1”, “best app in the world”, “make your baby genius”
- DON’T mention other brands
- DON’T use emoji spam in title
- DON’T duplicate the same description across languages with only names swapped

## Output format

Use this exact structure for each of the 5 apps:

### 1) English

**SEO**
- Primary keyword: `...`
- Secondary keywords: `...`
- Long-tail searches:
  - `...`
- Target countries: `...`

**Google Play**
- Title: `...` (xx/30)
- Short description: `...` (xx/80)
- Full description:
```
...
```
(xx chars)

**App Store**
- Name: `...` (xx/30)
- Subtitle: `...` (xx/30)
- Promotional text: `...` (xx/170)
- Description:
```
...
```
(xx chars)
- Keywords: `...` (xx/100)

**IDs**
- Android applicationId: `...`
- iOS bundle ID: `...`

**English check:** title = `...` | short = `...` | primary = `...`

Then repeat for French, Italian, Japanese, Spanish.

After all 5, add two tables:

**Listing table**

| Language | Play title | Primary keyword | Android ID | iOS ID |
|---|---|---|---|---|

**SEO table**

| Language | Primary keyword | Title uses it? | Short desc uses it? | Extra App Store keywords |
|---|---|---|---|---|

Do not add extra commentary before or after. Only the 5 listings + the 2 tables.
