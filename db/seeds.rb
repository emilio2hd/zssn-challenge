# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

Resource.create([{ name: 'Water', points: 4 }, { name: 'Food', points: 3 },
                 { name: 'Medication', points: 2 }, { name: 'Ammunition', points: 1 }])