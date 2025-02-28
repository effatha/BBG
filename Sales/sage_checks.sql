SELECT top 100 belegdatum,* --MAX(BelID)
FROM KHKVKBelege --where belegdatum > getdate()-1
order by belid desc

SELECT top 10 *
FROM KHKVKBelegePositionen order by belposid desc

---102070601 MAX BELID

--- 104647238 max belposid


SELECT top 10 *
FROM KHKBuchungsjournal order by id desc
---maxid 211850824



SELECT top 10 *
FROM KHKVKBelegeZKD order by id desc