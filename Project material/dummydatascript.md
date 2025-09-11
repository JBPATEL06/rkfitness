title: Supabase Dummy Data Script description: SQL script to populate the Supabase database with 15 initial dummy entries for all tables.
-- Insert 15 dummy users into the "User" table
INSERT INTO "User" ("Gmail", "weight", "bmi", "gender", "age", "Streak", "height", "Profile Picture")
VALUES
('john.doe@example.com', 75.5, 24.5, 'Male', 30, 5, 175.0, 'https://placehold.co/200x200'),
('jane.smith@example.com', 62.1, 22.8, 'Female', 25, 12, 165.5, 'https://placehold.co/200x200'),
('peter.jones@example.com', 85.0, 27.3, 'Male', 45, 2, 180.0, 'https://placehold.co/200x200'),
('susan.williams@example.com', 58.0, 21.0, 'Female', 34, 8, 160.0, 'https://placehold.co/200x200'),
('mike.brown@example.com', 90.0, 28.1, 'Male', 29, 20, 185.0, 'https://placehold.co/200x200'),
('emily.davis@example.com', 65.4, 23.5, 'Female', 22, 15, 170.0, 'https://placehold.co/200x200'),
('chris.wilson@example.com', 78.9, 25.1, 'Male', 38, 4, 178.0, 'https://placehold.co/200x200'),
('lisa.moore@example.com', 55.6, 20.5, 'Female', 27, 10, 158.0, 'https://placehold.co/200x200'),
('david.taylor@example.com', 72.3, 24.0, 'Male', 50, 3, 172.0, 'https://placehold.co/200x200'),
('laura.anderson@example.com', 60.0, 22.0, 'Female', 31, 6, 168.0, 'https://placehold.co/200x200'),
('paul.thomas@example.com', 81.2, 26.5, 'Male', 41, 9, 179.0, 'https://placehold.co/200x200'),
('mary.white@example.com', 63.8, 23.0, 'Female', 26, 14, 166.0, 'https://placehold.co/200x200'),
('steven.harris@example.com', 76.0, 24.8, 'Male', 33, 7, 174.0, 'https://placehold.co/200x200'),
('jessica.martin@example.com', 59.5, 21.5, 'Female', 29, 11, 162.0, 'https://placehold.co/200x200'),
('daniel.thompson@example.com', 88.5, 27.9, 'Male', 36, 18, 182.0, 'https://placehold.co/200x200');

-- Insert 15 dummy workouts into the "Workout Table"
INSERT INTO "Workout Table" ("Workout id", "Workout Name", "Workout type", "Workout Categor", "sets", "reps", "duration", "Gif Path", "Description")
VALUES
(gen_random_uuid(), 'Luffy Push-ups', 'exercise', 'Chest', 3, 10, NULL, 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'A standard push-up with a cool theme.'),
(gen_random_uuid(), 'Running: 30-min Jog', 'cardio', 'Cardio', NULL, NULL, '00:30:00', 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'A light jog to get the heart rate up.'),
(gen_random_uuid(), 'Squats', 'exercise', 'Legs', 4, 12, NULL, 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'Build strong legs and core.'),
(gen_random_uuid(), 'Plank Hold', 'exercise', 'Core', 3, NULL, '00:01:00', 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'Strengthen your abdominal muscles and back.'),
(gen_random_uuid(), 'Bicep Curls', 'exercise', 'Arms', 3, 15, NULL, 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'Tone and strengthen your biceps.'),
(gen_random_uuid(), 'Yoga Flow', 'cardio', 'Flexibility', NULL, NULL, '00:45:00', 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'A series of poses to improve flexibility and balance.'),
(gen_random_uuid(), 'Deadlifts', 'exercise', 'Back', 3, 8, NULL, 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'A full-body strength exercise.'),
(gen_random_uuid(), 'Jumping Jacks', 'cardio', 'Cardio', NULL, NULL, '00:10:00', 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'A quick cardio warm-up.'),
(gen_random_uuid(), 'Shoulder Press', 'exercise', 'Shoulders', 4, 10, NULL, 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'Build strength in your shoulders.'),
(gen_random_uuid(), 'Lunges', 'exercise', 'Legs', 3, 10, NULL, 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'Work your quads, hamstrings, and glutes.'),
(gen_random_uuid(), 'Swimming', 'cardio', 'Cardio', NULL, NULL, '00:45:00', 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'A great full-body cardio workout.'),
(gen_random_uuid(), 'Pull-ups', 'exercise', 'Back', 3, 5, NULL, 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'Strengthen your back and arms.'),
(gen_random_uuid(), 'High Knees', 'cardio', 'Cardio', NULL, NULL, '00:05:00', 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'A high-intensity warm-up.'),
(gen_random_uuid(), 'Tricep Dips', 'exercise', 'Arms', 3, 12, NULL, 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'Targets the triceps for a toned look.'),
(gen_random_uuid(), 'Burpees', 'exercise', 'Full Body', 3, 8, NULL, 'https://imgs.search.brave.com/Zl2Mr84zSJ2SZt1x9lWKLEE4Ec3ZNGMbqxD5UqNmU7k/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9wcmV2/aWV3LnJlZGQuaXQv/d2hhdHMteW91ci1m/YXZvcml0ZS1sdWZm/eS1pbWFnZS12MC1m/YTdveHZ4YmRqaWUx/LmpwZWc_d2lkdGg9/NTM1JmF1dG89d2Vi/cCZzPTdhYTUyNGY1/Y2ZmNzI0YzcxMjI0/NTIzYmMxNDhiMzFk/ZjMxNGRlYWE', 'A challenging full-body compound exercise.');

-- Insert 15 dummy notifications
INSERT INTO "notification" ("id", "tittle", "description")
VALUES
(gen_random_uuid(), 'Welcome!', 'Welcome to the RKU Fitness App! We are glad you are here.'),
(gen_random_uuid(), 'Workout Complete', 'Great job on completing your workout today! Keep up the good work.'),
(gen_random_uuid(), 'New Achievement', 'You have hit a new workout streak of 7 days!'),
(gen_random_uuid(), 'Reminder', 'Your scheduled workout is coming up in 1 hour.'),
(gen_random_uuid(), 'Check-in Time', 'Don''t forget to log your progress for the day.'),
(gen_random_uuid(), 'Weekly Summary', 'You've burned an estimated 2500 calories this week.'),
(gen_random_uuid(), 'Workout Suggestion', 'Try out the "Burpees" workout for a full-body challenge.'),
(gen_random_uuid(), 'Hydration Alert', 'Remember to drink water throughout the day.'),
(gen_random_uuid(), 'New Content', 'A new workout routine has been added to the library.'),
(gen_random_uuid(), 'App Update', 'A new version of the app is available with bug fixes.'),
(gen_random_uuid(), 'Personal Best', 'You just beat your personal record on push-ups!'),
(gen_random_uuid(), 'Time to Rest', 'Your body needs rest. Enjoy your day off from workouts.'),
(gen_random_uuid(), 'Community News', 'A new challenge is starting in the community section.'),
(gen_random_uuid(), 'Progress Check', 'You are on track to meet your fitness goals for the month.'),
(gen_random_uuid(), 'Quote of the Day', 'The only bad workout is the one that didn''t happen.');

-- Insert 15 dummy user progress entries
INSERT INTO "user Progress" ("id", "day", "workout count", "all complete", "time stamp")
VALUES
(gen_random_uuid(), 'Monday', 2, TRUE, NOW()),
(gen_random_uuid(), 'Tuesday', 1, TRUE, NOW() - INTERVAL '1 day'),
(gen_random_uuid(), 'Wednesday', 3, TRUE, NOW() - INTERVAL '2 days'),
(gen_random_uuid(), 'Thursday', 1, FALSE, NOW() - INTERVAL '3 days'),
(gen_random_uuid(), 'Friday', 2, TRUE, NOW() - INTERVAL '4 days'),
(gen_random_uuid(), 'Saturday', 1, TRUE, NOW() - INTERVAL '5 days'),
(gen_random_uuid(), 'Sunday', 0, FALSE, NOW() - INTERVAL '6 days'),
(gen_random_uuid(), 'Monday', 1, TRUE, NOW() - INTERVAL '7 days'),
(gen_random_uuid(), 'Tuesday', 2, FALSE, NOW() - INTERVAL '8 days'),
(gen_random_uuid(), 'Wednesday', 1, TRUE, NOW() - INTERVAL '9 days'),
(gen_random_uuid(), 'Thursday', 3, TRUE, NOW() - INTERVAL '10 days'),
(gen_random_uuid(), 'Friday', 2, TRUE, NOW() - INTERVAL '11 days'),
(gen_random_uuid(), 'Saturday', 1, FALSE, NOW() - INTERVAL '12 days'),
(gen_random_uuid(), 'Sunday', 2, TRUE, NOW() - INTERVAL '13 days'),
(gen_random_uuid(), 'Monday', 1, TRUE, NOW() - INTERVAL '14 days');

-- Insert 15 dummy scheduled workout entries
INSERT INTO "schedual workout" ("id", "user_id", "workout_id", "day_of_week", "order_in_day")
VALUES
(gen_random_uuid(), 'john.doe@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Luffy Push-ups' LIMIT 1), 'Monday', 1),
(gen_random_uuid(), 'jane.smith@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Running: 30-min Jog' LIMIT 1), 'Tuesday', 1),
(gen_random_uuid(), 'peter.jones@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Squats' LIMIT 1), 'Wednesday', 1),
(gen_random_uuid(), 'susan.williams@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Plank Hold' LIMIT 1), 'Thursday', 1),
(gen_random_uuid(), 'mike.brown@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Bicep Curls' LIMIT 1), 'Friday', 1),
(gen_random_uuid(), 'emily.davis@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Yoga Flow' LIMIT 1), 'Saturday', 1),
(gen_random_uuid(), 'chris.wilson@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Deadlifts' LIMIT 1), 'Monday', 2),
(gen_random_uuid(), 'lisa.moore@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Jumping Jacks' LIMIT 1), 'Tuesday', 2),
(gen_random_uuid(), 'david.taylor@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Shoulder Press' LIMIT 1), 'Wednesday', 2),
(gen_random_uuid(), 'laura.anderson@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Lunges' LIMIT 1), 'Thursday', 2),
(gen_random_uuid(), 'paul.thomas@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Swimming' LIMIT 1), 'Friday', 2),
(gen_random_uuid(), 'mary.white@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Pull-ups' LIMIT 1), 'Saturday', 2),
(gen_random_uuid(), 'steven.harris@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'High Knees' LIMIT 1), 'Monday', 3),
(gen_random_uuid(), 'jessica.martin@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Tricep Dips' LIMIT 1), 'Tuesday', 3),
(gen_random_uuid(), 'daniel.thompson@example.com', (SELECT "Workout id" FROM "Workout Table" WHERE "Workout Name" = 'Burpees' LIMIT 1), 'Wednesday', 3);