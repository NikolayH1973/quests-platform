-- ============================================
-- СХЕМА БАЗЫ ДАННЫХ: Платформа квестов по Израилю
-- Файл: database/01_schema.sql
-- СУБД: PostgreSQL (Supabase)
-- Создаёт 9 таблиц + индексы для быстрого поиска
-- ============================================

-- 1) USERS — родители/покупатели
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  password_hash VARCHAR(255),
  is_admin BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_users_email ON users(email);

-- 2) QUESTS — сами квесты (Ашдод-Ям и т.д.)
CREATE TABLE quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) UNIQUE NOT NULL,
  description TEXT,
  short_description VARCHAR(500),
  location VARCHAR(255) NOT NULL,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  image_url VARCHAR(500),
  base_price DECIMAL(10, 2) DEFAULT 20.00,
  author_id UUID REFERENCES users(id) ON DELETE SET NULL,
  is_published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_quests_slug ON quests(slug);
CREATE INDEX idx_quests_published ON quests(is_published);

-- 3) QUEST_VERSIONS — версии квеста по возрастам (7-9, 10-12, 13-15)
CREATE TABLE quest_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quest_id UUID NOT NULL REFERENCES quests(id) ON DELETE CASCADE,
  age_group VARCHAR(20) NOT NULL,
  difficulty VARCHAR(20),
  description TEXT,
  pdf_url VARCHAR(500),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(quest_id, age_group)
);
CREATE INDEX idx_quest_versions_quest ON quest_versions(quest_id);

-- 4) QUESTIONS — вопросы внутри версии квеста
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quest_version_id UUID NOT NULL REFERENCES quest_versions(id) ON DELETE CASCADE,
  question_number INT NOT NULL,
  question_text TEXT NOT NULL,
  question_type VARCHAR(20),
  hint TEXT,
  max_points INT DEFAULT 10,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(quest_version_id, question_number)
);
CREATE INDEX idx_questions_version ON questions(quest_version_id);

-- 5) QUESTION_OPTIONS — варианты ответов (для вопросов с выбором)
CREATE TABLE question_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  option_number INT NOT NULL,
  option_text VARCHAR(500) NOT NULL,
  is_correct BOOLEAN DEFAULT FALSE,
  UNIQUE(question_id, option_number)
);
CREATE INDEX idx_options_question ON question_options(question_id);

-- 6) PURCHASES — покупки
CREATE TABLE purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  quest_id UUID NOT NULL REFERENCES quests(id) ON DELETE CASCADE,
  num_children INT NOT NULL CHECK (num_children >= 1 AND num_children <= 5),
  base_price DECIMAL(10, 2) NOT NULL,
  discount_percent INT DEFAULT 0,
  total_price DECIMAL(10, 2) NOT NULL,
  payment_method VARCHAR(50),
  payment_id VARCHAR(255),
  payment_status VARCHAR(50) DEFAULT 'pending',
  email_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_purchases_user ON purchases(user_id);
CREATE INDEX idx_purchases_status ON purchases(payment_status);

-- 7) QUEST_CODES — уникальные коды (по одному на ребёнка)
CREATE TABLE quest_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_id UUID NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
  code VARCHAR(50) UNIQUE NOT NULL,
  code_number INT NOT NULL,
  child_name VARCHAR(255),
  status VARCHAR(50) DEFAULT 'unused',
  generated_at TIMESTAMP DEFAULT NOW(),
  used_at TIMESTAMP,
  UNIQUE(purchase_id, code_number)
);
CREATE INDEX idx_codes_code ON quest_codes(code);
CREATE INDEX idx_codes_status ON quest_codes(status);

-- 8) QUEST_COMPLETIONS — завершения квеста ребёнком
CREATE TABLE quest_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quest_code_id UUID NOT NULL REFERENCES quest_codes(id) ON DELETE CASCADE,
  quest_id UUID NOT NULL REFERENCES quests(id) ON DELETE CASCADE,
  quest_version_id UUID NOT NULL REFERENCES quest_versions(id),
  age_group VARCHAR(20) NOT NULL,
  completed_by_child_name VARCHAR(255),
  email_for_certificate VARCHAR(255),
  photo_url VARCHAR(500),
  total_score INT DEFAULT 0,
  max_score INT DEFAULT 0,
  completion_percentage INT,
  certificate_generated BOOLEAN DEFAULT FALSE,
  certificate_sent BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_completions_code ON quest_completions(quest_code_id);
CREATE INDEX idx_completions_quest ON quest_completions(quest_id);

-- 9) COMPLETION_ANSWERS — ответы ребёнка на вопросы
CREATE TABLE completion_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  completion_id UUID NOT NULL REFERENCES quest_completions(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id),
  user_answer TEXT NOT NULL,
  is_correct BOOLEAN,
  points_earned INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_answers_completion ON completion_answers(completion_id);
