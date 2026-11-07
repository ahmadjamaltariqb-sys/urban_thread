-- ========================================================
-- AL-NAHAL IMPEX — Supabase Products Database Setup Script
-- ========================================================

-- 1. Create Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    subtitle TEXT,
    price_usd NUMERIC(10,2) DEFAULT 0,
    price_pkr INTEGER DEFAULT 0,
    moq TEXT,
    lead_time TEXT,
    rating TEXT DEFAULT 'AQL 1.5 ★',
    badge TEXT,
    badge_class TEXT DEFAULT 'bg-primary text-on-primary',
    category TEXT[] DEFAULT ARRAY['men'],
    image TEXT NOT NULL,
    description TEXT,
    swatches JSONB DEFAULT '[]'::jsonb,
    display_order SERIAL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- 3. Allow Public to read all products (everyone can view)
DROP POLICY IF EXISTS "Allow public read access" ON public.products;
CREATE POLICY "Allow public read access" ON public.products FOR SELECT USING (true);

-- 4. Allow all operations (Insert, Update, Delete)
DROP POLICY IF EXISTS "Allow all for authenticated and anon" ON public.products;
CREATE POLICY "Allow all for authenticated and anon" ON public.products FOR ALL USING (true) WITH CHECK (true);

-- 5. Enable Realtime on products table
ALTER PUBLICATION supabase_realtime ADD TABLE public.products;

-- 6. Insert all AL-NAHAL IMPEX Products
INSERT INTO public.products (id, title, subtitle, price_usd, price_pkr, moq, lead_time, rating, badge, badge_class, category, image, description, swatches)
VALUES
(
  'p1',
  'Export Spec: 280 GSM Drop-Shoulder Heavy T-Shirt',
  'Knitwear • 100% Indus Long-Staple Combed Cotton',
  4.80, 1350, '100 pcs / color', 'Sample: 5-7 Days • Bulk: 20-25 Days',
  'AQL 1.5 ★', 'OEM / PRIVATE LABEL', 'bg-primary text-on-primary',
  ARRAY['men', 'casual', 'new'],
  'images/p1_base.jpg',
  'Heavyweight drop-shoulder blank engineered for international streetwear labels. 280 GSM combed cotton with high-density 1x1 ribbed collar that resists collar baconing through 50+ industrial washes. Pre-shrunk, bio-washed, and reactive dyed with OEKO-TEX certified pigments.',
  '[{"name": "Chalk White", "hex": "#f1eee7", "img": "images/p1_base.jpg"}, {"name": "Obsidian", "hex": "#1c1c18", "img": "images/p1_obsidian.jpg"}, {"name": "Olive Taupe", "hex": "#615e55", "img": "images/p1_olive.jpg"}, {"name": "Raw Oatmeal", "hex": "#8c7b6c", "img": "images/p1_oatmeal.jpg"}]'::jsonb
),
(
  'p2',
  'Export Spec: 420 GSM Loopback French Terry Hoodie',
  'Heavyweight Fleece • Custom Cut & Sew Silhouette',
  11.50, 3200, '100 pcs / color', 'Sample: 7 Days • Bulk: 25-30 Days',
  'AQL 1.5 ★', 'EXPORT BESTSELLER', 'bg-primary text-on-primary',
  ARRAY['men', 'casual', 'new'],
  'images/p2_base.jpg',
  'Heavyweight 420 GSM 100% cotton diagonal loopback French Terry. Features double-layered architectural hood with zero drawstrings (clean minimalist cut), flatlock 5-thread stitching, seamless kangaroo front pouch, and 450 GSM 2x2 lycra-reinforced ribbed cuffs.',
  '[{"name": "Washed Charcoal", "hex": "#242526", "img": "images/p2_base.jpg"}, {"name": "Alabaster", "hex": "#d6cfc4", "img": "images/p2_alabaster.jpg"}, {"name": "Deep Espresso", "hex": "#403b35", "img": "images/p2_espresso.jpg"}]'::jsonb
),
(
  'p3',
  'Export Spec: 13.5 oz Shuttle-Loom Selvedge Denim',
  'Denim Mill • Red-Line Selvedge & Vintage Wash',
  14.80, 4150, '150 pcs / style', 'Sample: 8-10 Days • Bulk: 30-35 Days',
  'AQL 1.5 ★', 'DENIM DIVISION', 'bg-surface-container-highest text-on-surface',
  ARRAY['men', 'casual', 'new'],
  'images/p3_base.jpg',
  'Manufactured on vintage shuttle looms in our Karachi denim unit using 100% ring-spun Pakistani cotton yarn. 13.5 oz right-hand twill with authentic red-line selvedge ID, custom brass shank buttons, copper rivets, and optional sustainable ozone wash.',
  '[{"name": "Raw Indigo", "hex": "#1b263b", "img": "images/p3_base.jpg"}, {"name": "Sulfur Black", "hex": "#202022", "img": "images/p3_black.jpg"}]'::jsonb
),
(
  'p4',
  'Export Spec: Textured Rib-Knit Polo Shirt',
  'Knitwear • Extra Long Staple Combed Cotton',
  8.20, 2300, '120 pcs / color', 'Sample: 6 Days • Bulk: 25 Days',
  'AQL 1.5 ★', 'EXPORT SPEC', 'bg-tertiary-container text-on-tertiary-container',
  ARRAY['men', 'new', 'sale'],
  'images/p4_base.jpg',
  'Fine-gauge vertical ribbed knit polo with seamless knit collar and tonal engraved mother-of-pearl or matte horn buttons. Engineered silhouette for elevated casualwear and corporate private labels.',
  '[{"name": "Warm Mushroom", "hex": "#b5a8a3", "img": "images/p4_base.jpg"}, {"name": "Jet Black", "hex": "#141518", "img": "images/p4_black.jpg"}, {"name": "Dusty Sage", "hex": "#96a19d", "img": "images/p4_sage.jpg"}]'::jsonb
),
(
  'p5',
  'Export Spec: Structured Cotton Gabardine Trench',
  'Woven Division • Water-Resistant Cotton Twill',
  18.50, 5180, '100 pcs / color', 'Sample: 8-10 Days • Bulk: 30-35 Days',
  'AQL 1.5 ★', 'WOVEN DIVISION', 'bg-primary text-on-primary',
  ARRAY['women', 'new'],
  'images/p5_base.jpg',
  'Heavy-duty 320 GSM cotton gabardine trench dress and overcoat. Tailored with double-breasted storm flap, reinforced epaulets, belted waist with wrapped buckle, and premium cupro internal lining.',
  '[{"name": "Sand Beige", "hex": "#d5c7b8", "img": "images/p5_base.jpg"}, {"name": "Obsidian", "hex": "#1c1c18", "img": "images/p5_obsidian.jpg"}, {"name": "Warm Ivory", "hex": "#f4f1ea", "img": "images/p5_ivory.jpg"}]'::jsonb
),
(
  'w2',
  'Export Spec: Extra-Fine Merino Ribbed Mockneck',
  'Knitwear • 7-Gauge Fully-Fashioned Knit',
  16.00, 4480, '100 pcs / color', 'Sample: 7 Days • Bulk: 28 Days',
  'AQL 1.5 ★', 'SWEATER DIVISION', 'bg-primary text-on-primary',
  ARRAY['women', 'new'],
  'images/w2_base.jpg',
  'Computerized Shima Seiki flat-knitted mockneck sweater. Extra-fine 19.5 micron Australian merino yarn blended with long-staple cotton for zero itch, structural shape retention, and luxury handfeel.',
  '[{"name": "Heather Ivory", "hex": "#eae6df", "img": "images/w2_base.jpg"}, {"name": "Obsidian Black", "hex": "#1e1e1e", "img": "images/w2_black.jpg"}, {"name": "Warm Taupe", "hex": "#78716c", "img": "images/w2_taupe.jpg"}]'::jsonb
),
(
  'p8',
  'Export Spec: Raw Silk & Linen Kimono Blazer',
  'Artisanal Weaves • Hand-Loomed Indigenous Silk',
  15.50, 4340, '80 pcs / style', 'Sample: 8 Days • Bulk: 28 Days',
  'AQL 1.5 ★', 'CAPSULE ATELIER', 'bg-tertiary-container text-on-tertiary-container',
  ARRAY['women', 'sale'],
  'images/p8_base.jpg',
  'Unlined artisanal wrap jacket woven from organic raw silk and Belgian flax linen on heritage Pakistani handlooms. Clean Hong-Kong bound interior seams, dropped kimono armholes, and subtle slub texture.',
  '[{"name": "Obsidian Silk", "hex": "#181818", "img": "images/p8_base.jpg"}, {"name": "Raw Bone", "hex": "#e2ddd5", "img": "images/p8_bone.jpg"}]'::jsonb
),
(
  'w4',
  'Export Spec: Belgian-Weave Tailored Linen Coat',
  'Woven Division • Heavyweight Pre-Washed Linen',
  19.50, 5460, '80 pcs / style', 'Sample: 9 Days • Bulk: 30 Days',
  'AQL 1.5 ★', 'TAILORED WOVEN', 'bg-surface-container-highest text-on-surface',
  ARRAY['women', 'sale'],
  'images/w4_base.jpg',
  'Longline unstructured summer trench cut from 260 GSM pure flax linen. Pick-stitched notched lapels, deep welt pockets, and real horn buttons.',
  '[{"name": "Natural Oat", "hex": "#d8cfc2", "img": "images/w4_base.jpg"}, {"name": "Deep Slate", "hex": "#2b2d2f", "img": "images/w4_slate.jpg"}]'::jsonb
),
(
  'p6',
  'Export Spec: Vegetable-Tanned Leather Carryall',
  'Leather Division • Top-Grain Cowhide & Brass Hardware',
  21.00, 5880, '50 pcs / color', 'Sample: 7 Days • Bulk: 25 Days',
  'AQL 1.5 ★', 'LEATHER GOODS', 'bg-primary text-on-primary',
  ARRAY['accessories'],
  'images/p6_base.jpg',
  'Export-spec leather carryall tote hand-finished in our Lahore leather unit using heavy 2.2mm full-grain cowhide leather, solid cast brass rivets, YKK Excella zippers, and reinforced double handles.',
  '[{"name": "Cognac Tan", "hex": "#8a5a36", "img": "images/p6_base.jpg"}, {"name": "Dark Espresso", "hex": "#3b281e", "img": "images/p6_espresso.jpg"}]'::jsonb
),
(
  'c1',
  'Export Spec: 380 GSM Vintage Crewneck Sweatshirt',
  'Knitwear • High-Density Diagonal Fleece',
  9.50, 2660, '100 pcs / color', 'Sample: 5-7 Days • Bulk: 25 Days',
  'AQL 1.5 ★', 'CORE KNITWEAR', 'bg-surface-container-highest text-on-surface',
  ARRAY['casual'],
  'images/c1_base.jpg',
  'Classic athletic raglan and drop-shoulder crewneck constructed from 380 GSM combed cotton fleece with vintage V-insert triangle stitch at neckline. Ideal for screen printing, embroidery, and high-density branding.',
  '[{"name": "Heather Grey", "hex": "#d3d3d3", "img": "images/c1_base.jpg"}, {"name": "Washed Black", "hex": "#2b2b2b", "img": "images/c1_base.jpg"}]'::jsonb
),
(
  'b1',
  'Export Spec: Relaxed Double-Pleat Chino Trouser',
  'Bottoms Division • 280 GSM Cotton Twill',
  10.80, 3020, '120 pcs / color', 'Sample: 7 Days • Bulk: 25 Days',
  'AQL 1.5 ★', 'EXPORT SPEC', 'bg-primary text-on-primary',
  ARRAY['men', 'casual'],
  'images/b1_base.jpg',
  'Wide-leg double-pleated casual work trouser crafted from high-tensile 280 GSM cotton twill. Features bar-tacked stress points, deep slant pockets, welt back pockets, and YKK zip fly.',
  '[{"name": "Warm Sand", "hex": "#d8ccb8", "img": "images/b1_base.jpg"}, {"name": "Military Olive", "hex": "#5e5b4c", "img": "images/b1_base.jpg"}]'::jsonb
),
(
  'b2',
  'Export Spec: 450 GSM Heavyweight Fleece Jogger',
  'Knitwear • Pre-Shrunk Custom Fit',
  11.20, 3130, '100 pcs / color', 'Sample: 6 Days • Bulk: 25 Days',
  'AQL 1.5 ★', 'HEAVY FLEECE', 'bg-surface-container-highest text-on-surface',
  ARRAY['men', 'casual'],
  'images/b2_base.jpg',
  'Ultra-heavyweight 450 GSM fleece sweatpants featuring elasticated waistband with elongated cotton drawcord, deep side pockets, rear patch pocket, and elasticated ankle cuffs.',
  '[{"name": "Vintage Black", "hex": "#1f1f21", "img": "images/b2_base.jpg"}, {"name": "Chalk Cream", "hex": "#ede8dd", "img": "images/b2_base.jpg"}]'::jsonb
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  subtitle = EXCLUDED.subtitle,
  price_usd = EXCLUDED.price_usd,
  price_pkr = EXCLUDED.price_pkr,
  moq = EXCLUDED.moq,
  lead_time = EXCLUDED.lead_time,
  rating = EXCLUDED.rating,
  badge = EXCLUDED.badge,
  badge_class = EXCLUDED.badge_class,
  category = EXCLUDED.category,
  image = EXCLUDED.image,
  description = EXCLUDED.description,
  swatches = EXCLUDED.swatches;
