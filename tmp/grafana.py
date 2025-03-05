#!/usr/bin/env python3
import sys
import requests
from requests.auth import HTTPBasicAuth
import json

# --------------------------------
'''

    # sbx
    db_url = ""
    db_user = 'grafana'
    db_password = ""


'''

DEV_USERS = {}

# --------------------------------

DEV_URL = ""
DEV_KEY = ""
DEV_PASSWORD = ""

# --------------------------------

actions = {'get-org': {'path': '/api/org', 'form': 'Bearer', 'verb': 'GET'},
           'add-api-key': {'path': '/api/auth/keys', 'form': 'Basic', 'verb': 'POST'},
           'add-user': {'path': '/api/admin/users', 'form': 'Basic', 'verb': 'POST'},
           'add-user-to-org': {'path': '/api/org/users', 'form': 'Bearer', 'verb': 'POST'},
           'add-dashboard': {'path': '/api/dashboards/db', 'form': 'Bearer', 'verb': 'POST'},
           'add-datasource': {'path': '/api/datasources', 'form': 'Bearer', 'verb': 'POST'},
           'add-folder': {'path': '/api/folders', 'form': 'Bearer', 'verb': 'POST'},
           'get-dashboard': {'path': '/api/dashboards/uid/%s', 'form': 'Bearer', 'verb': 'GET'},
           'get-datasources': {'path': '/api/datasources', 'form': 'Bearer', 'verb': 'GET'},
           'get-user': {'path': '/api/users', 'form': 'Basic', 'verb': 'GET'},
           'get-stats': {'path': '/api/admin/stats', 'form': 'Basic', 'verb': 'GET'},
           'list-dashboards': {'path': '/api/search?folderIds=0&query=&starred=false', 'form': 'Bearer', 'verb': 'GET'},
           'list-folders': {'path': '/api/folders', 'form': 'Bearer', 'verb': 'GET'},
           'list-orgs': {'path': '/api/orgs', 'form': 'Basic', 'verb': 'GET'},
           'list-users': {'path': '/api/users', 'form': 'Basic', 'verb': 'GET'},
           'set-user-permissions': {'path': '/api/admin/users/%d/permissions', 'form': 'Basic', 'verb': 'PUT'},
           'update-user': {'path': '/api/orgs/%d/users/%d', 'form': 'Basic', 'verb': 'PATCH'},
           }

# --------------------------------
# common utils


def generate_header(key, form=None):
    if form == 'Bearer':
        if key is None:
            raise ValueError('Need an API key')
        else:
            return {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': f'Bearer {key}'}
    else:
        return {'Accept': 'application/json', 'Content-Type': 'application/json'}


def send(action_name, url, key, username='admin', password=None, data=None, path=None):
    # print('')
    # print('send: %s' % (action_name,))
    form = actions[action_name]['form']
    if path is None:
        path = actions[action_name]['path']
    verb = actions[action_name]['verb']
    # print(f'{verb}: {action_name} -> {path} {form}')

    if verb == 'GET':
        if form == 'Basic':
            auth = HTTPBasicAuth(username, password)
            return requests.get(url + path, headers=generate_header(key, form), auth=auth)
        elif form == 'Bearer':
            return requests.get(url + path, headers=generate_header(key, form))
        else:
            raise ValueError('Need either Basic or Bearer as form')
    elif verb == 'POST':
        print('POST: ' + json.dumps(data, indent=4))
        if form == 'Basic':
            auth = HTTPBasicAuth(username, password)
            return requests.post(url + path, headers=generate_header(key, form), json=data, auth=auth)
        elif form == 'Bearer':
            return requests.post(url + path, headers=generate_header(key, form), json=data)
        else:
            raise ValueError('Need either Basic or Bearer as form')
    elif verb == 'PUT':
        if form == 'Basic':
            auth = HTTPBasicAuth(username, password)
            return requests.put(url + path, headers=generate_header(key, form), json=data, auth=auth)
        elif form == 'Bearer':
            return requests.put(url + path, headers=generate_header(key, form), json=data)
        else:
            raise ValueError('Need either Basic or Bearer as form')
    elif verb == 'PATCH':
        if form == 'Basic':
            auth = HTTPBasicAuth(username, password)
            return requests.patch(url + path, headers=generate_header(key, form), json=data, auth=auth)
        elif form == 'Bearer':
            return requests.patch(url + path, headers=generate_header(key, form), json=data)
        else:
            raise ValueError('Need either Basic or Bearer as form')

    else:
        raise ValueError('Bad verb')


def dump(reply):
    print(reply.status_code)
    print(reply.reason)
    print(reply.url)
    print(reply.text)
    try:
        print(json.dumps(reply.json(), indent=4))
    except Exception as eck:
        print(eck)
    return

# --------------------------------
# adders


def create_api_key(url, password):
    action = 'add-api-key'
    data = {'name': 'adminkey', 'role': 'Admin', 'secondsToLive': '86400'}
    reply = send(action, url, None, password=password, data=data)
    return reply.json()['key']


def add_datasource(url, key, db_host, db_name, db_user, db_pass):

    data = {
        "name": "our_aws",
        "type": "postgres",
        "access": "proxy",
        "url": db_host,
        "database": db_name,
        "basicAuth": False,
        "isDefault": True,
        "typeLogoUrl": "public/app/plugins/datasource/postgres/img/postgresql_logo.svg",
        "password": db_pass,
        "user": db_user,
        "readOnly": False,
        "jsonData": {
            "connMaxLifetime": 0,
            "maxIdleConns": 20,
            "maxOpenConns": 20,
            "postgresVersion": 1000,
            "sslmode": "disable"
        }
    }
    dump(send('add-datasource', url, key, data=data))
    return


def add_user(url, key, user):
    dump(send('add-user', url, key, user))
    return


def add_user_to_org(url, key, role, login):
    data = {'role': role, 'loginOrEmail': login}
    dump(send('add-user-to-org', url, key, data=data))
    return

# --------------------------------
# getters


def get_datasources(url, key):
    dump(send('get-datasources', url, key))
    return


def get_org(url, key):
    dump(send('get-org', url, key))
    return


def get_stats(url, key):
    dump(send('get-stats', url, key))
    return


def get_user(url, key):
    dump(send('get-user', url, key))
    return


def get_user_id(url, key, user_name):
    users = send('list-users', url, key).json()
    for user in users:
        if user['login'] == user_name:
            return user['id']
    raise IndexError('No such user')

# --------------------------------
# listers


def list_dashboards(url, key):
    dump(send('list-dashboards', url, key))
    return


def list_folders(url, key):
    dump(send('list-folders', url, key))
    return


def list_orgs(url, key):
    dump(send('list-orgs', url, key))
    return


def list_users(url, key):
    dump(send('list-users', url, key))
    return


def list_all_dashboards(url, key):
    folders = list()
    r0 = send('list-folders', url, key)
    try:
        items = r0.json()
        # print(json.dumps(items, indent=4))
        for item in items:
            folders.append(item.get('id'))
    except Exception as eck:
        print(eck)

    for folder_id in folders:
        path = '/api/search?folderIds=%d&query=&starred=false' % folder_id
        r1 = send('list-dashboards', url, key, path=path)
        for dashboard in r1.json():
            uid = dashboard['uid']
            print(uid)
    return

# --------------------------------
# patchers


def update_user(url, key, uid, role):
    action = 'update-user'
    path = actions[action]['path'] % (1, uid)
    data = {'role': role}
    dump(send(action, url, key, data=data, path=path))
    return

# --------------------------------
# others


def promote_user_to_admin(url, key, user_name):
    user_id = get_user_id(user_name)
    data = {'isGrafanaAdmin': True}
    action = 'set-user-permissions'
    response = send(action, url, key, path=actions[action]['path'] % user_id, data=data)
    dump(response)
    return


def transfer_top_level(src_url, src_key, dst_url, dst_key):  # e.g. from sk3w.co
    folder_id = 0
    path = '/api/search?folderIds=%d&query=&starred=false' % folder_id
    r1 = send('list-dashboards', src_url, src_key, path=path)
    for dashboard in r1.json():
        uid = dashboard['uid']
        path = actions['get-dashboard']['path'] % uid
        r2 = send('get-dashboard', src_url, src_key, path=path)
        data = r2.json()
        data['dashboard']['id'] = None
        data['folderId'] = folder_id
        print(json.dumps(data))
        r3 = send('add-dashboard', dst_url, dst_key, data=data)
        print(r3.status_code)
    return


def transfer_with_folders(src_url, src_key, dst_url, dst_key):
    src_id = list()
    dest_id = list()
    r1 = send('list-dashboards', src_url, src_key)
    for k1 in r1.json():
        print('Adding folder')
        print(k1)
        src_id.append(k1['id'])
        data = {'uid': k1['uid'], 'title': k1['title']}
        r2 = send('add-folder', dst_url, dst_key, data=data)
        dump(r2)
        dest_id.append(r2.json()['id'])
    if len(src_id) != 2 or len(dest_id) != 2:
        print('mismatch on id lists')
        print(src_id)
        print(dest_id)
        return
    print('OK have folders')

    idx = 0
    for id in src_id:
        path = '/api/search?folderIds=%d&query=&starred=false' % id
        r1 = send('list-dashboards', src_url, src_key, path=path)
        for dashboard in r1.json():
            uid = dashboard['uid']
            path = actions['get-dashboard']['path'] % uid
            r2 = send('get-dashboard', src_url, src_key, path=path)
            print(r2.status_code)
            data = r2.json()
            data['dashboard']['id'] = None
            data['folderId'] = dest_id[idx]
            r3 = send('add-dashboard', dst_url, dst_key, data=data)
            print(r3.status_code)
        idx += 1
    return


# --------------------------------


if __name__ == '__main__':

    endpoint = DEV_URL
    apikey = DEV_KEY
    users = DEV_USERS
    # grafana_password = ""
    # grafana_password = ""
    # feeds_db_host = ""
    # feeds_db_name = ""
    # feeds_db_user = ""
    # feeds_db_pass = ""

    #list_folders(DEV_URL, DEV_KEY)
    #list_dashboards(DEV_URL, DEV_KEY)
    list_all_dashboards(DEV_URL, DEV_KEY)
    #print(endpoint)

    # create_api_key(endpoint, grafana_password)
    # add_datasource(endpoint, apikey, feeds_db_host, feeds_db_name, feeds_db_user, feeds_db_pass)
    # get_datasources(endpoint, apikey)

    #transfer_with_folders(DEV_URL, DEV_KEY, WEB01_URL, WEB01_KEY)
    #list_folders(WEB01_URL, WEB01_KEY)
    #list_dashboards(WEB01_URL, WEB01_KEY)

    # list_orgs(endpoint, apikey)
    # list_users(endpoint, apikey)
    changes = False

    if False:
        login = users['nick']['login']
        role = 'Editor'
        add_user(endpoint, apikey, users['nick'])
        add_user_to_org(endpoint, apikey, role, login)
        uid = get_user_id(endpoint, apikey, login)
        update_user(endpoint, apikey, uid, role)
        changes = True

    if False:
        login = users['tim1']['login']
        role = 'Editor'
        add_user(endpoint, apikey, users['tim1'])
        add_user_to_org(endpoint, apikey, role, login)
        uid = get_user_id(endpoint, apikey, login)
        update_user(endpoint, apikey, uid, role)
        changes = True

    if changes:
        list_users(endpoint, apikey)

    # transfer_with_folders(DEV_URL, DEV_KEY, SBX_URL, SBX_KEY)

    # transfer_top_level()
    # get_datasources()
    # list_folders()
    # get_org()
    # get_user()
    # get_stats()
    # list_users()
    # promote_user_to_admin('timShort')
    # get_stats()

    sys.exit(0)
