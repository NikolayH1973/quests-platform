-- ============================================
-- ТЕСТОВЫЕ ДАННЫЕ (SEED): квест "Крепость Ашдод-Ям"
-- Файл: database/03_seed.sql
-- Запускать ПОСЛЕ 01_schema.sql и 02_security.sql
-- Версии: children (семьи 7-13) / adults (взрослые)
-- ============================================

-- 1) Создаём квест
INSERT INTO quests (title, slug, description, short_description, location, latitude, longitude, base_price, is_published)
VALUES (
  'Крепость Ашдод-Ям',
  'ashdod-yam',
  'Средневековая крепость на берегу Средиземного моря. Исследуй древние камни, найди секретные знаки каменотёсов и разгадай загадки крепости.',
  'Квест-приключение в средневековой крепости на берегу моря',
  'Ашдод, Израиль',
  31.80721,
  34.64335,
  20.00,
  TRUE
);

-- 2) Версия для семей с детьми (children)
INSERT INTO quest_versions (quest_id, age_group, difficulty, description)
SELECT id, 'children', 'easy', 'Задания для семей с детьми 7-13 лет'
FROM quests WHERE slug = 'ashdod-yam';

-- 3) Два вопроса к детской версии
INSERT INTO questions (quest_version_id, question_number, question_text, question_type, max_points)
SELECT qv.id, 1, 'Сколько башен у крепости Ашдод-Ям?', 'choice', 10
FROM quest_versions qv
JOIN quests q ON qv.quest_id = q.id
WHERE q.slug = 'ashdod-yam' AND qv.age_group = 'children';

INSERT INTO questions (quest_version_id, question_number, question_text, question_type, max_points)
SELECT qv.id, 2, 'Какой символ вырезан на камнях крепости?', 'text', 10
FROM quest_versions qv
JOIN quests q ON qv.quest_id = q.id
WHERE q.slug = 'ashdod-yam' AND qv.age_group = 'children';

-- 4) Варианты ответов к вопросу №1
INSERT INTO question_options (question_id, option_number, option_text, is_correct)
SELECT q.id, 1, '2 башни', FALSE
FROM questions q
JOIN quest_versions qv ON q.quest_version_id = qv.id
JOIN quests qu ON qv.quest_id = qu.id
WHERE qu.slug = 'ashdod-yam' AND qv.age_group = 'children' AND q.question_number = 1;

INSERT INTO question_options (question_id, option_number, option_text, is_correct)
SELECT q.id, 2, '4 башни', TRUE
FROM questions q
JOIN quest_versions qv ON q.quest_version_id = qv.id
JOIN quests qu ON qv.quest_id = qu.id
WHERE qu.slug = 'ashdod-yam' AND qv.age_group = 'children' AND q.question_number = 1;
