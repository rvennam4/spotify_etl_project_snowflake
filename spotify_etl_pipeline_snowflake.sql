create schema spotify_pipeline;

CREATE OR REPLACE TABLE tblAlbum (
    album_id STRING PRIMARY KEY,
    name STRING,
    release_date DATE,
    total_tracks INTEGER,
    url STRING
);

CREATE OR REPLACE TABLE tblArtist (
    artist_id STRING PRIMARY KEY,
    artist_name STRING,
    external_url STRING
);

CREATE OR REPLACE TABLE tblSongs (
    song_id STRING PRIMARY KEY,
    song_name STRING,
    duration_ms INTEGER,
    url STRING,
    popularity INTEGER,
    song_added TIMESTAMP,
    album_id STRING REFERENCES tblAlbum(album_id),
    artist_id STRING REFERENCES tblArtist(artist_id)
);

CREATE OR REPLACE STORAGE INTEGRATION my_s3_integration
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'S3'
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::471112811445:role/snowflake_s3'
STORAGE_ALLOWED_LOCATIONS = ('s3://spotify-etl-project-ranjith/');



desc integration my_s3_integration;

CREATE OR REPLACE STAGE spotify_stage
URL = 's3://spotify-etl-project-ranjith/transformed_data/'
STORAGE_INTEGRATION = my_s3_integration;

LIST @spotify_stage;

COPY INTO tblAlbum
FROM @spotify_stage/album_data/
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

COPY INTO tblArtist
FROM @spotify_stage/artist_data/
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

COPY INTO tblSongs
FROM @spotify_stage/songs_data/
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

CREATE OR REPLACE PIPE album_pipe
AUTO_INGEST = TRUE
AS
COPY INTO tblAlbum
FROM @spotify_stage/album_data/
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

CREATE OR REPLACE PIPE artist_pipe
AUTO_INGEST = TRUE
AS
COPY INTO tblArtist
FROM @spotify_stage/artist_data/
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

CREATE OR REPLACE PIPE song_pipe
AUTO_INGEST = TRUE
AS
COPY INTO tblSongs
FROM @spotify_stage/songs_data/
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

SHOW PIPES;

SELECT * FROM tblAlbum LIMIT 10;
SELECT * FROM tblArtist LIMIT 10;
SELECT * FROM tblSongs LIMIT 10;

select count(*) from tblsongs;















