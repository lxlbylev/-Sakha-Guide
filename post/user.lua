local m = {
  [1] = { -- userID
    ["nick"] = "Sight",
    ["discriptionChannel"] = "Мой канал труляля", 
    ["subscribes"] = 0, 
    
    ["mail"] = "admin@gmail.com",
    ["password"] = "12345678",
    ["status"] = "admin",
    
    
    ["signupdate"] =  1666872784,
    

    ["posts"] = {1,2,3} -- myPostsID
    ["subTo"] = {
      2, -- userID
      3,
    },
    ["likeTo"] = {
      2, -- postID
      3,
    },

  }
}
m = {}

--[[
Соотношение гуманитария и технаря в вас примерно равны, может и есть незначительные перевесы в какую-либо сторону. Вы будете комфортно себя чувствовать как среди гуманитариев, так и с технарями. Ведь вы понимаете особенности поведения, что одних, что других. Знаете как подобрать особый подход. С гуманитариями вы будете делать акцент на эмоциях, чувствах. Технарям предоставите логику и аргументы, без лишних эмоций
]]
local json = require"json"
return json.encode(m)