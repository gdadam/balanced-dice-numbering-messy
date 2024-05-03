using Base.Threads
using BenchmarkTools
using .Iterators #: product


num_a = 0
num_b = 0
b_total = 0

total_checks = Atomic{Int64}(0)
solutions = Atomic{Int64}(0)

function remused(unused,x,d)
    xor(unused, ((1 << (x-1))|(1 << (d-x))))
end

function used(unused,x)
    0 == (unused & ((1 << (x-1))))
end
function nsed(unused,x)
    0 != (unused & ((1 << (x-1))))
end

function d24check(a1,a2,a3,a4,b1,b2,b3,b4,c1,c2,c3,c4)
    n2 = 25
    n4 = 2*n2
    n6 = 3*n2

    if(a1+a2+a3+a4 != n4)
        atomic_add!(check1_counter,1)
        return false
    end
    if(b1+b2+b3+b4 != n4)
        atomic_add!(check2_counter,1)
        return false
    end
    if(c1+c2+c3+c4 != n4)
        atomic_add!(check3_counter,1)
        return false
    end
    if(a1+a2+b1+b2+c1+c2 != n6)
        atomic_add!(check4_counter,1)
        return false
    end
    if(a2+a3+ (n2-b3)+(n2-b4)+c1+c4 != n6)
        atomic_add!(check5_counter,1)
        return false
    end
    if((n2-a3)+(n2-a4)+b2+b3+c2+c3 != n6)
        atomic_add!(check6_counter,1)
        return false
    end
    if(a1+a4+b1+b4+ (n2-c3)+(n2-c4) != n6)
        atomic_add!(check7_counter,1)
        return false
    end
    return true
end


function d24()

unused = 2^24-1
arr=[1:24;]
a1 = 1

unused_ai = remused(unused,a1,24)

for a2 in arr

    if(used(unused_ai,a2))
        continue
    end
    unused_aj = remused(unused_ai,a2,24) #this line removes conflicting face numbers
    for a3 in arr
        if(used(unused_aj,a3))
            continue
        end
        unused_ak = remused(unused_aj,a3,24)
        a4 = 50-a1-a2-a3
        if(nsed(unused_ak,a4))
            unused_b = remused(unused_ak,a4,24)
            #global num_a+=1
            for b1 in arr
                if(used(unused_b,b1))
                    continue
                end
                unused_bi = remused(unused_b,b1,24) #this line removes conflicting face numbers
                for b2 in arr
                    if(used(unused_bi,b2))
                        continue
                    end
                    unused_bj = remused(unused_bi,b2,24) #this line removes conflicting face numbers
                    for b3 in arr
                        if(used(unused_bj,b3))
                            continue
                        end
                        unused_bk = remused(unused_bj,b3,24) #this line removes conflicting face numbers
                        b4=50-(b1+b2+b3)
                        if(nsed(unused_bk,b4))
                            if(0 == a4 - a2 + b4 - b2) #checking a constraint, this could be used to eliminate a for loop
                                unused_c = remused(unused_bk,b4,24) #this line removes conflicting face numbers
                                for c1 in arr
                                    if(used(unused_c,c1))
                                        continue
                                    end
                                    unused_ci = remused(unused_c,c1,24)
                                    c2 = 75-a1-a2-b1-b2-c1
                                    if(nsed(unused_ci,c2))
                                        unused_cj = remused(unused_ci,c2,24)
                                        c3 = 75-((25-a3)+(25-a4)+b2+b3+c2) # (25-a3)+(25-a4)+b2+b3+c2+c3 == 75, c3=75-((25-a3)+(25-a4)+b2+b3+c2)
                                        if(nsed(unused_cj,c3)) #checking Z and Z`
                                            unused_ck = remused(unused_cj,c3,24)
                                            c4 = a1+a4+b1+b4-c3-25 # a1+a4+b1+b4+ (25-c3)+(25-c4) == 75, c4= a1+a4+b1+b4-c3-25
                                            if(nsed(unused_ck,c4)) #checking Y and Y`
                                                if(d24check(a1,a2,a3,a4,b1,b2,b3,b4,c1,c2,c3,c4))
                                                    atomic_add!(solutions,1)
                                                end
                                                println(a1,' ',a2,' ',a3,' ',a4,'|',b1,' ',b2,' ',b3,' ',b4,'|',c1,' ',c2,' ',c3,' ',c4,'|',25-c1,' ',25-c2,' ',25-c3,' ',25-c4,'|',25-b1,' ',25-b2,' ',25-b3,' ',25-b4,'|',25-a1,' ',25-a2,' ',25-a3,' ',25-a4)#   "success ", solutions[],' ',))
                                            else
                                                continue
                                            end
                                        else
                                            continue
                                        end
                                    else
                                        continue
                                    end
                                end
                            else
                                continue
                            end
                        else
                            continue
                        end
                    end
                end
            end
        else
            continue
        end
    #end
end
end
println(solutions)
end


flag = 0
#d48_counter = 0
d48_counter = Atomic{Int64}(0)


function d48()
    unused = 2^48-1
    arr=[2:47;]
    a1 = 1
    #for a1 in arr
    unused_ai = remused(unused,a1,48)
    #for a2 in 2:47
    Threads.@threads for x in (1:46*46-1)
        a2 = mod(x,46)+2
        a3 = div(x,46)+2
        #println("starting a2: ", a2, " a3: ", a3)
        #used(unused_ai,a2) && println("a")
        unused_aj = remused(unused_ai,a2,48) #this line removes conflicting face numbers
        #Threads.@threads for a3 in 2:47
            a4 = 98-a1-a2-a3
            (1<a4<48) || continue
            used(unused_aj,a3) && continue
            unused_ak = remused(unused_aj,a3,48)
            used(unused_ak,a4) && continue
            unused_b = remused(unused_ak,a4,48)
            for b1 in 2:47
                #println
                b2 = 98-b1-a1-a4
                (1<b2<48) || continue
                used(unused_b,b1) && continue
                unused_bi = remused(unused_b,b1,48) #this line removes conflicting face numbers
                used(unused_bi,b2) && continue
                unused_bj = remused(unused_bi,b2,48) #this line removes conflicting face numbers
                for b3 in 2:47
                    b4=98-b1-b2-b3
                    (1<b4<48) || continue
                    used(unused_bj,b3) && continue
                    unused_bk = remused(unused_bj,b3,48) #this line removes conflicting face numbers
                    used(unused_bk,b4) && continue
                    unused_c = remused(unused_bk,b4,48)
                    for c1 in 2:47
                        used(unused_c,c1) && continue
                        unused_ci = remused(unused_c,c1,48)
                        for c2 in 2:47
                            used(unused_ci,c2) && continue
                            unused_cj = remused(unused_ci,c2,48)
                            for c3 in 2:47
                                c4=98-c1-c2-c3
                                (1<c4<48) || continue
                                used(unused_cj,c3) && continue
                                unused_ck = remused(unused_cj,c3,48)
                                used(unused_ck,c4) && continue
                                unused_d = remused(unused_ck,c4,48)
                                #atomic_add!(d48_counter,1)
                                for d1 in 2:47
                                    d2 = 98-d1-c1-c2
                                    (1<d2<48) || continue
                                    used(unused_d,d1) && continue
                                    unused_di = remused(unused_d,d1,48)
                                    used(unused_di,d2) && continue
                                    d3 = 98 + a1 + a2 - b2 - b4 - c1 - c3 - d1
                                    (1<d3<48) || continue
                                    unused_dj = remused(unused_di,d2,48)
                                    used(unused_dj,d3) && continue
                                    d4 = 98-c3-c4-d3
                                    (1<d4<48) || continue
                                    unused_dk = remused(unused_dj,d3,48)
                                    used(unused_dk,d4) && continue
                                    unused_e = remused(unused_dk,d4,48)
                                    for e1 in 2:47
                                        e2 = 147-b1-b2-c1-c2-e1
                                        #println(b1+b2+c1+c2+e1+e2)
                                        (1<e2<48) || continue
                                        used(unused_e,e1) && continue
                                        unused_ei = remused(unused_e,e1,48)
                                        used(unused_ei,e2) && continue
                                        f1 = 0
                                        f1x2 = (a3 + a4 + b1 + b3 - c2 + c4 - d2 + d4 - e1 - e1)
                                        if(mod(f1x2,2)==0)
                                            f1 = div(f1x2,2)
                                        else
                                            continue
                                        end
                                        (1<f1<48) || continue
                                        unused_ej = remused(unused_e,e2,48)
                                        used(unused_ej, f1) && continue
                                        f2 = 98-e1-e2-f1
                                        (1<f2<48) || continue
                                        unused_ek = remused(unused_ej,f1,48)
                                        used(unused_ek,f2) && continue
                                        unused_f = remused(unused_ek,f2,48)
                                        for e3 in 2:47
                                            e4 = 98-e1-e2-e3
                                            (1<e4<48) || continue
                                            used(unused_f,e3) && continue
                                            unused_fi = remused(unused_f,e3,48)
                                            used(unused_fi,e4) && continue
                                            f3 = 147 - a3 - a4 - b1 - b3 - e2 - f2  + e4 #
                                            (1<f3<48) || continue
                                            unused_fj = remused(unused_fi,e4,48)
                                            used(unused_fj,f3) && continue
                                            #f4 = 196 - c4 - d4 - (49 - c2) - (49 - d2) - (49 - e1) - (49 - e3) - (49 - f1)
                                            f4 = c2 - c4 - d4  + d2 + e1 + e3 + f1 - 49
                                            (1<f4<48) || continue
                                            unused_fk = remused(unused_fj,f3,48)
                                            used(unused_fk,f4) &&continue
                                            atomic_add!(d48_counter,1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
    end
end



println(d48_counter)


println(num_a)
println(b_total)
