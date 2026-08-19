INSERT INTO users (id, email, first_name, last_name, role)
VALUES (
    '019a0000-0000-7000-8000-000000000001',
    'genkovich.beerphp@gmail.com',
    'Gennadiy',
    'Kovalyov',
    'admin'
) ON CONFLICT (email) DO NOTHING;
