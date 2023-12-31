-- =============================================
-- Author:		Kamil Dańczyszyn (KamDan)
-- Create date: 16.10.2023
-- Description:	Procedure calls external solution to fetch data from external databases.
-- exec [dbo].[importItem] 'sampleitem', '9999', 'kamdan', '127.0.0.1', 'masterdb', ''
-- select * from importItem_log order by rowcreateddt desc
-- =============================================

ALTER   PROCEDURE [dbo].[importItem] @Artnr     NVARCHAR(30), -- Item Number
                                                                 @Ftgnr     NVARCHAR(30),
                                                                 @Perssign  NVARCHAR(30),
                                                                 @SERVER    NVARCHAR(20),
                                                                 @DB_NAME   NVARCHAR(20),
                                                                 @ProcessID NVARCHAR(200)
AS
BEGIN
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_WARNINGS ON;
SET ANSI_PADDING ON;

    -- here we call CLR with artnr
    DECLARE @Api_url   NVARCHAR(1000),
            @Data2send NVARCHAR(1000),
            @Result    XML,
            @Headers   XML,
            @itemData  NVARCHAR(MAX)

    
    BEGIN TRY
        EXEC [dbo].[getconfig] 'Acquisition Import', @Api_url OUT
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE()
        RETURN
    END CATCH

    IF @ProcessID = ''
    BEGIN
        SELECT @ProcessID = NEWID();
    END;

    SELECT @Headers = '<Headers>
                        <Header Name="Content-Type">application/json</Header>
                       </Headers>';

    SET @Data2send = CONCAT('{"item_number":"', @ArtNr, '",
                            "ftgnr":"', @Ftgnr, '",
                            "perssign":"', @Perssign, '",
                            "server":"', @SERVER, '",
                            "dbname":"', @DB_NAME, '",
                            "processid":"', @ProcessID, '"
                            }');

    INSERT INTO [importItem_log]
        ([processid],
         [externalnr],
         [ftgnr],
         [msg],
         [ei],
         [perssign],
         [resultxml]
        )
    VALUES (@ProcessID, @Artnr, @Ftgnr, '', '', @Perssign, '');

    SELECT @Result = [dbo].[clrHTTP] ('POST', @Api_url, @Data2send, CAST(@Headers AS NVARCHAR(MAX)), NULL);

    SELECT @itemData = @Result.value('(//Response/Body)[1]', 'NVARCHAR(MAX)')

    UPDATE [importItem_log]
    SET
        [resultxml] = @Result,
        [JsonData] = @itemData
        --[EI] = CASE WHEN @itemData IS NULL THEN 'E' END
    WHERE [processid] = @ProcessID;

    -- EI <> 'E', 'E' is updated directly from python if error occurs
    IF (SELECT [EI] FROM importItem_Log where ProcessID = @processid) <> 'E'
        EXECUTE importItem_insert @processid
END;


