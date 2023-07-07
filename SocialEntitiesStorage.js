exports.newSocialTradingFunctionLibrariesSocialEntitiesStorage = function () {
     
    let thisObject = {
        saveSocialEntityAtStorage: saveSocialEntityAtStorage,
        loadSocialEntityFromStorage: loadSocialEntityFromStorage
    }

    return thisObject

    async function saveSocialEntityAtStorage(
        profileMessage
    ) {
        /*
        At this function we are going to save a Social Entity Profile using
        the Open Storage. The message format expected is:

        profileMessage = {
            originSocialPersonaId: "",      // Id of the Social Persona to be saved.
            profileData: "",                // Stringified version of the profile data to be saved. 
            profileType: SA.projects.socialTrading.globals.profileTypes.SAVE_SOCIAL_ENTITY
        }
        */

        return new Promise(saveSocialEntityAsync)

        async function saveSocialEntityAsync(resolve, reject) {
            /*
            Each Social Entity must have a Storage Container so that we can here
            use it to save content on it. 
            */
            let socialEntity
            if (profileMessage.originSocialPersonaId !== undefined) {
                let socialEntityId = profileMessage.originSocialPersonaId
                socialEntity = SA.projects.socialTrading.globals.memory.maps.SOCIAL_PERSONAS_BY_ID.get(socialEntityId)
            }
            if (profileMessage.originSocialTradingBotId !== undefined) {
                let socialEntityId = profileMessage.originSocialTradingBotId
                socialEntity = SA.projects.socialTrading.globals.memory.maps.SOCIAL_PERSONAS_BY_ID.get(socialEntityId)
            }
            /*
            Some Validations
            */
            if (socialEntity === undefined) {
                let response = {
                    result: 'Error',
                    message: 'Cannot Save Social Entity Profile Because Social Entity is Undefined'
                }
                resolve(response)
                return
            }

            let availableStorage = socialEntity.node.availableStorage
            if (availableStorage === undefined) {
                let response = {
                    result: 'Error',
                    message: 'Cannot Save Social Entity Profile Because Available Storage is Undefined'
                }
                resolve(response)
                return
            }

            if (availableStorage.storageContainerReferences.length === 0) {
                let response = {
                    result: 'Error',
                    message: 'Cannot Save Social Entity Profile Because Storage Container References is Zero'
                }
                resolve(response)
                return
            }
            /*
            Prepare the content to be saved
            */
            let fileContent = profileMessage.profileData
            let fileName = socialEntity.id
            let filePath = "Social-Entities"
            /*
            We are going to save this file at all of the Storage Containers defined.
            */
            let savedCount = 0
            let notSavedCount = 0

            for (let i = 0; i < availableStorage.storageContainerReferences.length; i++) {
                let storageContainerReference = availableStorage.storageContainerReferences[i]
                if (storageContainerReference.referenceParent === undefined) {
                    continue
                }
                if (storageContainerReference.referenceParent.parentNode === undefined) {
                    continue
                }

                let storageContainer = storageContainerReference.referenceParent

                switch (storageContainer.type) {
                    case 'Github Storage Container': {
                        await SA.projects.openStorage.utilities.githubStorage.saveFile(fileName, filePath, fileContent, storageContainer)
                            .then(onFileSaved)
                            .catch(onFileNodeSaved)
                        break
                    }
                    case 'Superalgos Storage Container': {
                        // TODO Build the Superalgos Storage Provider
                        break
                    }
                }

                function onFileSaved() {
                    savedCount++
                    if (savedCount + notSavedCount === availableStorage.storageContainerReferences.length) {
                        allFilesSaved()
                    }
                }

                function onFileNodeSaved() {
                    notSavedCount++
                    if (savedCount + notSavedCount === availableStorage.storageContainerReferences.length) {
                        allFilesSaved()
                    }
                }

                function allFilesSaved() {
                    if (savedCount > 0) {
                        let response = {
                            result: 'Ok',
                            message: 'Social Entity Saved'
                        }
                        resolve(response)
                    } else {
                        let response = {
                            result: 'Error',
                            message: 'Storage Provider Failed to Save at least 1 Social Entity File'
                        }
                        resolve(response)
                    }
                }
            }
        }
    }

    async function loadSocialEntityFromStorage(
        profileMessage
    ) {
        /*
        When the Web App makes a query that includes Post text as responses,
        we need to fetch the text from the the storage container of the author
        of such posts, since the Network Nodes do not store that info themselves, 
        they just store the structure of the social graph.
        */
        return new Promise(loadSocialEntityAsync)

        async function loadSocialEntityAsync(resolve, reject) {
            /*
            Each Social Entity must have a Storage Container so that we can here
            use it to load content on it. 
            */
            let socialEntity
            if (profileMessage.originSocialPersonaId !== undefined) {
                let socialEntityId = profileMessage.originSocialPersonaId
                socialEntity = SA.projects.socialTrading.globals.memory.maps.SOCIAL_PERSONAS_BY_ID.get(socialEntityId)
            }
            if (profileMessage.originSocialTradingBotId !== undefined) {
                let socialEntityId = profileMessage.originSocialTradingBotId
                socialEntity = SA.projects.socialTrading.globals.memory.maps.SOCIAL_PERSONAS_BY_ID.get(socialEntityId)
            }
            /*
            Some Validations
            */
            if (socialEntity === undefined) {
                let response = {
                    result: 'Error',
                    message: 'Cannot Load Social Entity Profile Because Social Entity is Undefined'
                }
                resolve(response)
                return
            }

            let availableStorage = socialEntity.node.availableStorage
            if (availableStorage === undefined) {
                let response = {
                    result: 'Error',
                    message: 'Cannot Load Social Entity Profile Because Available Storage is Undefined'
                }
                resolve(response)
                return
            }

            if (availableStorage.storageContainerReferences.length === 0) {
                let response = {
                    result: 'Error',
                    message: 'Cannot Load Social Entity Profile Because Storage Container References is Zero'
                }
                resolve(response)
                return
            }
            let file
            let notLoadedCount = 0

            for (let i = 0; i < availableStorage.storageContainerReferences.length; i++) {
                let storageContainerReference = availableStorage.storageContainerReferences[i]
                if (storageContainerReference.referenceParent === undefined) {
                    continue
                }
                if (storageContainerReference.referenceParent.parentNode === undefined) {
                    continue
                }

                let storageContainer = storageContainerReference.referenceParent

                if (file !== undefined) {
                    continue
                }
                /*
                We are going to load this file from the Storage Containers defined.
                We are going to try to read it first from the first Storage container
                and if it is not possible we will try with the next ones.
                */
                let fileName = socialEntity.id
                let filePath = "Social-Entities"

                switch (storageContainer.parentNode.type) {
                    case 'Github Storage': {
                        await SA.projects.openStorage.utilities.githubStorage.loadFile(fileName, filePath, storageContainer)
                            .then(onFileLoaded)
                            .catch(onFileNotLoaded)
                        break
                    }
                    case 'Superalgos Storage': {
                        // TODO Build the Superalgos Storage Provider
                        break
                    }
                }

                function onFileLoaded(fileData) {
                    file = fileData
                    let response = {
                        result: 'Ok',
                        message: 'Social Entity Profile Found',
                        profileData: file
                    }
                    resolve(response)
                }

                function onFileNotLoaded() {
                    notLoadedCount++
                    if (notLoadedCount === availableStorage.storageContainerReferences.length) {
                        let response = {
                            result: 'Error',
                            message: 'Social Entity Profile Not Available At The Moment'
                        }
                        resolve(response)
                    }
                }
            }
        }
    }
}
