
-- =============================================
-- Author:		KamDan (Kamil Dańczyszyn)
-- Description:	Procedure is used to fetch data from json send by Python integration.
/*
EXECUTE importItem_insert @processid = 'F4BA9352-5536-4456-B63A-4630153961D4'
*/
-- =============================================
CREATE PROCEDURE [dbo].[importItem_insert] @processid NVARCHAR(200)
AS
BEGIN
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
    DECLARE 
        @Message NVARCHAR(MAX) = '',
        @jsonData NVARCHAR(MAX),
        -- basic data
        @ItemNumber NVARCHAR(30),
        @newItemNumber NVARCHAR(30),
        @ftgnr NVARCHAR(20),
        @CompanyCode smallint = 1, -- master data default
        @perssign nvarchar(30),
        ---------------
		/*
			other fields
		*/
     

    IF NOT EXISTS (SELECT 1 FROM importItem_Log WHERE ProcessID = @processid)   
    BEGIN
        SELECT 'Error. Invalid Request. Procedure run out of context. ProcessID does not exists'
        RETURN;
    END

    ---------------------
    -- data extraction --
    ---------------------
    SELECT @jsonData = [JsonData],
            @ItemNumber = [ExternalNr],
            @ftgnr = [FtgNr],
            @perssign = [PersSign]
    FROM importItem_Log
    WHERE ProcessID = @processid

    IF ISJSON(@jsonData) <> 1
    BEGIN
        SELECT @Message = CONCAT('Invalid JSON', @jsonData)
        
        UPDATE importItem_Log
        SET Msg = @Message,
        EI = 'E'        
        WHERE ProcessID = @processid

        RETURN;
    END         
    
    -- Basic data empty
    IF @ItemNumber = '' or @ftgnr = '' or @perssign = ''
    BEGIN
        SELECT @Message = CONCAT('Basic Data missing, import failed. ItemNumber = ', @ItemNumber, 'Ftgnr = ', @ftgnr, 'Perssign = ', @perssign)

        UPDATE importItem_Log
        SET Msg = @Message,
        EI = 'E'
        WHERE ProcessID = @processid

        RETURN;
    END


    SELECT
        ------ item ------
        @ItemDescription = ISNULL(CONVERT(NVARCHAR(60), j2.ItemDescription), 'default_value'),
        /*
			other fields
		*/
    FROM OPENJSON(@jsonData)
    WITH (
        ItemDescription NVARCHAR(60),
        /*
			other fields
		*/
    ) as j2

    ----------------
    -- Validation --   
    ----------------

    -- Item origin group
    SELECT @mode = CASE 
        WHEN @www = 'www.github.com' THEN 'KamDan' 
        END
    
	-- some other validation

    -- START IMPORT
    BEGIN TRY
        -- Insert to [sometable] --
        IF NOT EXISTS (SELECT 1 FROM sometable WHERE ItemNumber = @newItemNumber and CompanyCode = @CompanyCode)
        BEGIN    
           INSERT INTO sometable (some columns)
           VALUES (some values)
        END
        ELSE
        BEGIN
            UPDATE sometable
            SET     somefields = somevalues
            WHERE ItemNumber = @newItemNumber and CompanyCode = @CompanyCode
        END

    -- Insert to [othertable] --
        EXECUTE someProcedure @someParams                                   

    -- Update on [othertable] fields --
        UPDATE [othertable]
        SET somefields = somevalues
        WHERE ItemNumber = @newItemNumber and CompanyCode = @CompanyCode

        SELECT @Message = CONCAT('Import of item ', @newItemNumber, ' successfull')

        UPDATE importItem_Log
        SET Msg = @Message,
        EI = 'I',
        HlItemNumber = @newItemNumber
        WHERE ProcessID = @processid

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        ROLLBACK;
        
        SELECT @Message = CONCAT(@@ERROR, ERROR_MESSAGE())

        UPDATE importItem_Log
        SET Msg = @Message,
        EI = 'E'
        WHERE ProcessID = @processid
    END CATCH
END


