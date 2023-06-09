create database lab10;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  age INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO users (name, email, age) VALUES ('Alex', 'alex@gmail.com', 25);
INSERT INTO users (name, email, age) VALUES ('Kristin', 'kris.com', 30);
INSERT INTO users (name, email, age) VALUES ('Theon', 'theon@.com', 35);

CREATE TABLE posts (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO posts (title, body, user_id) VALUES ('Post 1', 'first post', 1);
INSERT INTO posts (title, body, user_id) VALUES ('2', 'post', 2);
INSERT INTO posts (title, body, user_id) VALUES ('Post 3', 'third post', 3);

CREATE TABLE comments (
  id SERIAL PRIMARY KEY,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL REFERENCES users(id),
  post_id INTEGER NOT NULL REFERENCES posts(id),
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO comments (body, user_id, post_id) VALUES (' 1  post 1', 2, 1);
INSERT INTO comments (body, user_id, post_id) VALUES (' 2  post 1', 3, 1);
INSERT INTO comments (body, user_id, post_id) VALUES (' 1  post 2', 1, 2);
INSERT INTO comments (body, user_id, post_id) VALUES (' 2  post 2', 3, 2);
INSERT INTO comments (body, user_id, post_id) VALUES (' 1  post 3', 1, 3);
INSERT INTO comments (body, user_id, post_id) VALUES (' 2  post 3', 2, 3);

CREATE TABLE replies (
    id SERIAL PRIMARY KEY,
    comment_id INTEGER NOT NULL REFERENCES comments(id),
    user_id INTEGER NOT NULL REFERENCES users(id),
    reply_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);INSERT INTO replies (comment_id, user_id, reply_text)
VALUES (1, 2, 'Коммент');

INSERT INTO replies (comment_id, user_id, reply_text)
VALUES (1, 3, 'Коммент');

INSERT INTO replies (comment_id, user_id, reply_text)
VALUES (2, 3, 'Коммент');

INSERT INTO replies (comment_id, user_id, reply_text)
VALUES (3, 1, 'Ну и зачем Вы это написали?');


CREATE OR REPLACE FUNCTION check_age()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.age < 18 THEN
    RAISE EXCEPTION 'Возраст должен быть не меньше 18 лет';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_users
BEFORE INSERT ON users
FOR EACH ROW
EXECUTE FUNCTION check_age();


CREATE OR REPLACE FUNCTION add_created_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.created_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_posts
AFTER INSERT ON posts
FOR EACH ROW
EXECUTE FUNCTION add_created_at();

CREATE VIEW comments_view AS
SELECT id, body, user_id, post_id, created_at
FROM comments;

CREATE OR REPLACE FUNCTION insert_product_with_supplier() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO posts (title, body, user_id, created_at)
    VALUES (NEW.product_name, NEW.price, NEW.supplier_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER instead_of_insert_product_with_supplier
INSTEAD OF INSERT ON comments_view
FOR EACH ROW
EXECUTE FUNCTION insert_product_with_supplier();
