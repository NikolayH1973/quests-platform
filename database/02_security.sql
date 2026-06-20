-- ============================================
-- БЕЗОПАСНОСТЬ: Row Level Security (RLS)
-- Файл: database/02_security.sql
-- СУБД: PostgreSQL (Supabase)
-- ============================================

-- 1) Включаем RLS на всех 9 таблицах (закрываем двери по умолчанию)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE quest_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE quest_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quest_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE completion_answers ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 2) ПОЛИТИКИ: публичное чтение "витринных" таблиц
-- ============================================

-- Опубликованные квесты может читать кто угодно (витрина магазина)
CREATE POLICY "public_read_published_quests"
  ON quests FOR SELECT
  USING (is_published = TRUE);

-- Активные версии квестов может читать кто угодно (нужно для каталога)
CREATE POLICY "public_read_quest_versions"
  ON quest_versions FOR SELECT
  USING (is_active = TRUE);

-- Вопросы может читать кто угодно (нужны для формы прохождения)
CREATE POLICY "public_read_questions"
  ON questions FOR SELECT
  USING (TRUE);

-- Варианты ответов может читать кто угодно
CREATE POLICY "public_read_question_options"
  ON question_options FOR SELECT
  USING (TRUE);

-- ============================================
-- ПРИМЕЧАНИЕ: таблицы users, purchases, quest_codes,
-- quest_completions, completion_answers намеренно оставлены
-- БЕЗ публичных политик. К ним обращается только backend
-- через секретный service_role ключ (обходит RLS).
-- Чувствительные операции не идут через браузер.
-- ============================================
