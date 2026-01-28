
// Consts 
perishables:`apples`bread`milk`carrots`eggs`yogurt`cheese`lettuce`tomatoes`grapes`banana;

// Step 1. Load in inventory text into a kdb table (csv formatted)
inventory:("SF";enlist ",") 0: `:inventory.txt;

// Step 2. Add perishable column
inventory:update perishable:1b from inventory where name in perishables;

// Step 3. Clean inventory
  / a. Remove expired items
inventory:delete from inventory where quantity<=0;
  / b. Group any duplicated items (leave keyed to make next step easier)
inventory:select quantity:sum quantity by name from inventory;

// Step 4. Update and replenish
inventory[`banana]+:5;
inventory[`rice]+:10;
inventory[`chocolate]+:3;

