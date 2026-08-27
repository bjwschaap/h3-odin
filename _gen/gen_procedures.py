# usage: python3 ./gen_procedures.py > ../procedures.odin
import re

f_src = open("h3api.h", "r")

append_next = False
a_line = ''
lines = []

header = '''
package h3

import c "core:c"

Index :: u64
Error :: u32

when ODIN_OS == .Darwin && ODIN_ARCH == .amd64 {
	foreign import lib "_gen/libh3_darwin_amd64.a"
} else when ODIN_OS == .Darwin && ODIN_ARCH == .arm64 {
	foreign import lib "_gen/libh3_darwin_arm64.a"
} else when ODIN_OS == .Linux && ODIN_ARCH == .amd64 {
	foreign import lib "_gen/libh3_linux_amd64.a"
} else when ODIN_OS == .Linux && ODIN_ARCH == .arm64 {
	foreign import lib "_gen/libh3_linux_arm64.a"
}

@(default_calling_convention="c")
foreign lib {
'''

print(header)
for line in f_src:
    if line.startswith('DECLSPEC'):
        a_line += line
        if ';' not in line:
            append_next = True
            continue
        else:
            append_next = False
            lines.append(a_line)
            a_line = ''
            continue

    if append_next:
        a_line += line
        if ';' in line:
            append_next = False
            lines.append(a_line)
            a_line = ''
            continue

def convert_type(t):
    if t == 'int':
        return 'int'
    elif t == 'H3Error':
        return 'Error'
    elif t == 'double':
        return 'f64'
    elif t == 'void':
        return ''
    elif t == 'int64_t':
        return 'i64'
    elif t == 'H3Index':
        return 'Index'
    elif t == 'uint32_t':
        return 'u32'
    elif t == 'size_t':
        return 'u64'
    else:
        return t

def get_return_type(t):
    if t == 'void':
        return ''
    else:
        return ' -> ' + convert_type(t)

def get_args_types(args):
    result = ''
    # C headers may spell an empty parameter list as either () or (void).
    if len(args) == 1 and args[0].strip() in ('', 'void'):
        return result
    for arg in args:
        tokens = arg.lstrip().split(' ')
        if len(tokens) % 2 == 1:
            raise Exception('Invalid argument: ' + arg)
        
        for i in range(0, len(tokens), 2):
            param_type = convert_type(tokens[i].replace('$',''))
            param_name = tokens[i+1].replace('^','')
            # if tokens[i+1].startswith('^') and param_type == 'cstring':
            #     pass
            # elif
            if tokens[i+1].startswith('^'):
                param_type = '^'+param_type
            
            if tokens[i].startswith('$'):
                param_name = param_name #TODO '$'+param_name
            result += param_name + ': ' + param_type + ', '
    return result.removesuffix(', ')        


abi_template = "\t{} :: proc ( {} ){} ---"

for l in lines:
    refining = l.replace('\n', ''
                ).replace('DECLSPEC ', ''
                ).replace(');', ''
                ).replace('const char *','cstring '
                ).replace('char *','[]u8 '
                ).replace('H3_EXPORT',''
                ).replace(')',''
                ).replace('const ', '$'
                ).replace('*', '^')
    
    refining = re.sub(r'( )+', ' ', refining)

    return_type = get_return_type(refining.split(' ')[0].lstrip())
    refined2 = refining.split('(')
    args = refined2[2].split(',')
    args_converted = get_args_types(args)
    print(abi_template.format(refined2[1], args_converted, return_type))

print('\n}')
