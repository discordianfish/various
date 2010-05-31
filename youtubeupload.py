#!/usr/bin/env python
import gdata.youtube.service
import gdata.youtube
import ConfigParser
import re
import os
import sys

DEV_KEY = 'AI39si4TYH4syN6-g8GTg7FG8VlNQeI5h-YN4O99xLw5Oaqb0fIiBMOdyhZteYvHUp0bxUY_sSrjlYcMhov-nSBGMZhvYkmjAA'
CLIENT_ID = 'fish-yt-uploader'

client = gdata.youtube.service.YouTubeService()

config = ConfigParser.ConfigParser()

config.read(os.environ['HOME'] + "/.youtube.conf")

# client.ClientLogin(config.get('account','user'), config.get('account','pass'))
try:
	client.email = config.get('account','user')
	client.password = config.get('account','pass')

except:
	sys.exit("error reading ~/.youtube.conf. Should be look like that:\n[account]\nuser: foo@example.com\npass: foobar23")

client.source = CLIENT_ID
client.client_id = CLIENT_ID
client.developer_key = DEV_KEY

client.ProgrammaticLogin()


try:
	file = sys.argv[1]
except(IndexError):
	print "%s path/to/video" % ( sys.argv[0] )
	sys.exit(1)

if not os.path.isfile(file):
	print "'%s' does not exist or is no file" %( file )
	sys.exit(1)
	


title = re.sub(r'\.[^\.]*$', '', file);
title = re.sub(r'_', ' ', title)

meta = gdata.media.Group(
	title = gdata.media.Title(text=title),
	description = gdata.media.Description(description_type='plain', text='auto upload'),
	keywords = gdata.media.Keywords(text='tbd'),
	category = [gdata.media.Category(
        text='Entertainment',
        scheme='http://gdata.youtube.com/schemas/2007/categories.cat',
        label='Entertainment')],
	player=None
)

entry = gdata.youtube.YouTubeVideoEntry(media=meta)

ret = client.InsertVideoEntry(entry, file)
