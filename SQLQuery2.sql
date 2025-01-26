create TABLE [dbo].[netflix_raw](
[show_id][varchar](10) primary key,
[type][varchar](10) null,
[title][nvarchar](200) null,
[director][varchar](250) null,
[cast][varchar](1000) null,
[country][varchar](150) null,
[date_added][varchar](20) null,
[release_year][int] null,
[rating][varchar](10) null,
[duration][varchar](10) null,
[listed_in][varchar](100) null,
[description][varchar](500) null,
)
GO
