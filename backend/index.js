// ============================================
// BACKEND СЕРВЕР — главный файл
// Платформа квестов по Израилю
// ============================================

require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

// Подключение к базе данных Supabase
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SECRET_KEY
);

const app = express();
app.use(cors());
app.use(express.json());

// Проверка, что сервер жив
app.get('/', (req, res) => {
  res.json({ message: 'Backend квестов работает! 🚀', status: 'ok' });
});

// ENDPOINT 1: список всех опубликованных квестов
app.get('/api/quests', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('quests')
      .select('*')
      .eq('is_published', true);

    if (error) {
      return res.status(500).json({ error: error.message });
    }

    res.json({ count: data.length, quests: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ENDPOINT 2: один квест по slug + его версии и вопросы
// Адрес: /api/quests/ashdod-yam
app.get('/api/quests/:slug', async (req, res) => {
  try {
    const { slug } = req.params;

    const { data, error } = await supabase
      .from('quests')
      .select(`
        *,
        quest_versions (
          id,
          age_group,
          difficulty,
          description,
          questions (
            id,
            question_number,
            question_text,
            question_type,
            max_points
          )
        )
      `)
      .eq('slug', slug)
      .eq('is_published', true)
      .single();

    if (error) {
      return res.status(404).json({ error: 'Квест не найден' });
    }

    res.json({ quest: data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Запускаем сервер
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Сервер запущен: http://localhost:${PORT}`);
});
