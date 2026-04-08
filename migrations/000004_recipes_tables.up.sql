DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'recipe_category') THEN
        CREATE TYPE recipe_category AS ENUM ('entrante', 'primer_plato', 'segundo_plato', 'postre', 'salsa', 'bebida');
    END IF;
END$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'unit_type') THEN
        CREATE TYPE unit_type AS ENUM ('kg', 'g', 'l', 'ml', 'ud', 'cucharada', 'pizca');
    END IF;
END$$;


CREATE TABLE IF NOT EXISTS recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID REFERENCES establishments(id) ON DELETE CASCADE,
    name VARCHAR NOT NULL,
    description TEXT,
    category recipe_category,
    portion_size_kg NUMERIC(10,4),
    servings INTEGER DEFAULT 1,
    preparation_time INTEGER,
    version INTEGER DEFAULT 1,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL -- Coma eliminada
);

CREATE TABLE IF NOT EXISTS recipe_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    instruction TEXT NOT NULL,
    duration INTEGER CHECK (duration >= 0),
    UNIQUE (recipe_id, step_number) 
);

CREATE TABLE IF NOT EXISTS recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    ingredient_id UUID REFERENCES ingredients(id) ON DELETE RESTRICT,
    sub_recipe_id UUID REFERENCES recipes(id) ON DELETE RESTRICT,
    quantity NUMERIC(10,4) NOT NULL CHECK (quantity >= 0),
    unit unit_type NOT NULL,
    is_optional BOOLEAN DEFAULT FALSE,

    CONSTRAINT ingredient_or_subrecipe CHECK (
        (ingredient_id IS NOT NULL AND sub_recipe_id IS NULL) OR 
        (ingredient_id IS NULL AND sub_recipe_id IS NOT NULL)
    )
);

CREATE TABLE IF NOT EXISTS recipe_allergens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    allergen_id UUID REFERENCES allergens(id) ON DELETE CASCADE,
    is_manual BOOLEAN DEFAULT FALSE,
    contains BOOLEAN DEFAULT TRUE,
    UNIQUE (recipe_id, allergen_id) 
);

CREATE TABLE IF NOT EXISTS recipe_alternatives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    alternative_recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    reason TEXT,
    CHECK (recipe_id <> alternative_recipe_id) 
);
