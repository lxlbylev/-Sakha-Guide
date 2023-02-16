local m = {
  users = {
    [1] = { -- userID
      ["nick"] = "Sight",
      ["discriptionChannel"] = "Мой канал труляля", 
      ["subscribes"] = 0, 
      
      ["mail"] = "admin@gmail.com",
      ["password"] = "12345678",
      ["status"] = "admin",
      
      
      ["signupdate"] =  1666872784,
      
      ["posts"] = {1,2,3}, -- myPostsID

      ["notifTo"] = {2}, -- publisherID
      ["subTo"] = {2, 3}, -- publisherID
      ["likeTo"] = {2, 3}, -- postID

    }
  },

  posts = {
    [1] = { -- postID
      ["publisherID"] = 1
      
      ["images"] = #photoForPost,
      
      ["title"] = titleField.text,
      ["text"] = longField.text,
      
      ["datePost"] = time,
      
      ["likes"] = 0,
      ["comments"] = {
        userID = 2,
        date = os.time(),
        text = "HII",
      },
    }
  }
}
m = {}

--[[
Соотношение гуманитария и технаря в вас примерно равны, может и есть незначительные перевесы в какую-либо сторону. Вы будете комфортно себя чувствовать как среди гуманитариев, так и с технарями. Ведь вы понимаете особенности поведения, что одних, что других. Знаете как подобрать особый подход. С гуманитариями вы будете делать акцент на эмоциях, чувствах. Технарям предоставите логику и аргументы, без лишних эмоций
]]
local json = require"json"
return json.encode(m)