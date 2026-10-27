total = hit = 0

with open('coverage/lcov.info') as file:
    for line in file:
        if line.startswith('LF:'):
            total += int(line[3:])
        elif line.startswith('LH:'):
            hit += int(line[3:])

if total > 0:
    print(f'{hit}/{total} lines covered = {hit/total*100:.1f}%')
else:
    print('No coverage data found')