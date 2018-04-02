#!/usr/bin/env python
import re
import sys

re_label = re.compile('^[ \t]*(?P<label>[a-z_-]+):$')
re_open_scope = re.compile('[ \t]*\\.\\(.*')
re_close_scope = re.compile('[ \t]*\\.\\).*')
re_comment = re.compile('[ \t]*;(?P<comment>.*)')

api = []

def usage():
	print("usage: find ../nine/ -name '*.asm' | xargs ./generate_routines_list.py")
	sys.exit(1)

if len(sys.argv) == 1:
	usage()

for filename in sys.argv[1:]:
	if filename[0] == '-':
		usage()

	with open(filename, 'r') as src_file:
		depth = 0
		comment = ''
		for line in src_file:
			line = line[:-1]

			if re_open_scope.match(line):
				depth += 1

			if re_close_scope.match(line):
				depth -= 1

			if depth == 0:
				m = re_label.match(line)
				if m is not None:
					api.append({'name': m.group('label'), 'doc': comment[:-1]})

				m = re_comment.match(line)
				if m is not None:
					comment = '%s%s\n' % (comment, m.group('comment'))
				else:
					comment = ''

api.sort(key=lambda x: x['name'])
for routine in api:
	print(routine['name'])
	print('-'*len(routine['name']))
	print('')
	if routine['doc'] != '':
		print('::')
		print('')
		print('\t%s' % (routine['doc'].replace('\n', '\n\t'),))
		print('')
