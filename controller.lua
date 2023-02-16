local c = {}
c.newLocalDataBase = function(name)
	local mas = {}
	mas.loadBase = function()
		local file = io.open( system.pathForFile( name..".json", system.DocumentsDirectory ), "r" )
    
    local data
    if file then
      data = file:read( "*a" )
      io.close( file )

    else
      data = {}

      local file = io.open( system.pathForFile( name..".json", system.DocumentsDirectory ), "w" )
 
      if file then
        file:write( data )
        io.close( file )
      end

    end 
    return data
	end

	mas.saveBase = function()
		local file = io.open( system.pathForFile( name..".json", system.DocumentsDirectory ), "w" )
 
    if file then
      file:write( json.encode( mas.loadedData ) )
      io.close( file )
    end
	end

	mas.loadedData = mas.loadBase()

	return mas
end

c.blogerAccountsDataBase = function()
	local mas = c.newLocalDataBase("post")
	local standartProfilePhoto = "img/chat_profile.png"

	mas.getUserByID = function( userID )
		for k,v in pairs(mas.loadedData) do
			if v.id==userID then
				return v
			end
		end
		error("User#"..userID.." not found")
	end

	mas.getAccountLogoPath = function( userID )
		local user = mas.getUserByID( userID )
		return (user.nick):lower().."_logo.png"
	end

	mas.initUser = function( realID )
		mas.loadedData.users[realID] = {
      -- id = realID,
      discription = "Fire Communtity 2022",
      subcribes = 0,
      post = {},

      likeTo = {},
      subTo = {},
      notifTo = {},
    }

    local a = display.newImage(standartProfilePhoto, q.cx, q.cy)
    a.x = -q.fullw
    display.save( a, { filename=mas.getAccountLogoPath( realID ) , baseDir=system.DocumentsDirectory, captureOffscreenArea=true, backgroundColor={0,0,0,0} } )
    display.remove( a )
    
	end

	mas.userToPublisher = function( userID, publisherID )
		if userID==publisherID then error("User and publisher cannot have the same ID - "..userID) end
		return mas.getUserByID(userID), mas.getUserByID(publisherID)
	end

	mas.isUserLikePost = function( userID, publisherID, postID )
		local user, publisher = mas.userToPublisher( userID, publisherID )
		local post = publisher.post[postID]

		for i=1, #user.likeTo do
      if user.likeTo[i]==post.id then
        return true
      end
    end
    return false
	end

	mas.likePost = function( userID, publisherID, postID )
		local user, publisher = mas.userToPublisher( userID, publisherID )
		local post = publisher.post[postID]

		if mas.isUserLikePost(userID, publisherID, postID)==true then
			error("Post#"..postID.." already liked by User#"..userID)
			return false
		end
		user.likeTo[#user.likeTo+1] = postID
    post.likes = post.likes + 1
	end

	mas.unlikePost = function( userID, publisherID, postID )
		local user, publisher = mas.userToPublisher( userID, publisherID )
		local post = publisher.post[postID]

		if mas.isUserLikePost(userID, publisherID, postID)==false then
			error("Post#"..postID.." already don't liked by User#"..userID)
			return false
		end

		for i=1, #user.likeTo do
      if user.likeTo[i]==postID then
        table.remove(user.likeTo, i)
        break
      end
    end
    post.likes = post.likes - 1
	end

	mas.isUserSubscribedTo = function( userID, publisherID )
		local user, publisher = mas.userToPublisher( userID, publisherID )

    for i=1, #user.subTo do
      if user.subTo[i]==publisherID then
        return true
      end
    end
    return false
	end

	mas.subcribe = function( userID, publisherID )
		local user, publisher = mas.userToPublisher( userID, publisherID )
		
		if mas.isUserSubscribedTo( userID, publisherID ) then
			error("User#"..userID.." already subcribed to Publisher#"..publisherID)
			return false
		end

		publisher.subcribes = publisher.subcribes + 1
    user.subTo[#user.subTo+1] = publisherID
	end

	mas.unsubscribe = function()
		local user, publisher = mas.userToPublisher( userID, publisherID )
		
		if mas.isUserSubscribedTo( userID, publisherID )==false then
			error("User#"..userID.." already don't subcribed to Publisher#"..publisherID)
			return false
		end

		publisher.subcribes = publisher.subcribes - 1
    for i=1, #user.subTo do
      if user.subTo[i]==publisherID then
        table.remove(user.subTo, i)
        break
      end
    end
	end


	mas.getSubToList = function( userID )
	end

	

	mas.addPost = function( publisherID, image )
	end

	mas.changeDiscripton = function( userID, newDiscription )
	end

end

return c