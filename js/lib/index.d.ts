type EffectCallback = () => (void | (() => void | undefined));
type SetStateAction<A> = (value: A) => void;
type DependencyList = ReadonlyArray<any>;

export declare function setTimeout(action: () => void, delay: number): void

export declare function useState<A>(): [A, SetStateAction<A>];
export declare function useEffect(effect: EffectCallback, deps?: DependencyList): void;
export declare function useCallback<T extends (...args: any[]) => any>(callback: T, deps: DependencyList): T;

