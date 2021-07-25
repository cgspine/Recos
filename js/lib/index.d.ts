type EffectCallback = () => (void | (() => void | undefined));
type SetStateAction<A> = (value: A) => void;
type DependencyList = ReadonlyArray<any>;

export declare function setTimeout(action: () => void, delay: number): void

export declare function useState<A>(initValue: A): [A, SetStateAction<A>];

export declare function useEffect(effect: EffectCallback, deps?: DependencyList): void;

export declare function useCallback<T extends (...args: any[]) => any>(callback: T, deps: DependencyList): T;


export declare function View(style: Object,
                             onClick: () => void)

export declare function Text(style: Object,
                             onClick: () => void)

export declare function RecyclerView(style: Object,
                                     spanCount: number = 1,
                                     direction: string = 'column',
                                     count: number,
                                     render: (number) => any)

export declare function StaggeredVerticalGrid(style: Object,
                                              spanCount: number,
                                              count: number,
                                              render: (number) => any)

export declare function Crossfade<T>(targetState: T, content: (targetState: T) => any)

