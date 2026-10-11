import nx from '@nx/eslint-plugin';

export default [
    ...nx.configs['flat/base'],
    ...nx.configs['flat/typescript'],
    {
        files: ['**/*.ts', '**/*.tsx'],
        rules: {
            // 프로젝트 태그로 import 방향을 강제한다. 위반은 lint 에러.
            '@nx/enforce-module-boundaries': [
                'error',
                {
                    enforceBuildableLibDependency: false,
                    allow: [],
                    depConstraints: [
                        // 앱은 라이브러리만 가져올 수 있다
                        {sourceTag: 'type:app', onlyDependOnLibsWithTags: ['type:lib']},
                        // 라이브러리는 라이브러리만 가져올 수 있다 (앱 금지)
                        {sourceTag: 'type:lib', onlyDependOnLibsWithTags: ['type:lib']},
                        // 도메인은 아무것도 가져오지 않는다
                        {sourceTag: 'scope:core', onlyDependOnLibsWithTags: []}
                    ]
                }
            ]
        }
    },
    {ignores: ['**/dist', '**/node_modules']}
];
