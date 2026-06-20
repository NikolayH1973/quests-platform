require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SECRET_KEY
);

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Backend квестов работает! 🚀', status: 'ok' });
});

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

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Сервер запущен: http://localhost:${PORT}`);
});
